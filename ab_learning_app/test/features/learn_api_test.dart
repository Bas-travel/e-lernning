import 'dart:typed_data';

import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/core/network/rest_client.dart';
import 'package:ab_learning_app/core/network/token_store.dart';
import 'package:ab_learning_app/features/learn/data/learn_repository.dart';
import 'package:ab_learning_app/features/learn/presentation/learn_sample_data.dart';
import 'package:ab_learning_app/features/learn/presentation/learn_screen.dart';
import 'package:ab_learning_app/core/theme/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_helpers.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final String body;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeLearn implements LearnRepository {
  _FakeLearn(this.courses, {this.failLoads = 0});

  List<EnrolledCourse> courses;
  int failLoads;

  @override
  bool get bundledOnly => false;

  @override
  Future<List<EnrolledCourse>> enrolled() async {
    if (failLoads > 0) {
      failLoads--;
      throw Exception('offline');
    }
    return courses;
  }
}

const _two = [
  EnrolledCourse(
    id: '7',
    title: 'Go เบื้องต้น',
    progress: 0.62,
    gradient: AppGradients.brand,
    resumeRoute: '/player/55',
  ),
  EnrolledCourse(
    id: '8',
    title: 'Flutter จริงจัง',
    progress: 0,
    gradient: AppGradients.brand,
    resumeRoute: '/course/8',
  ),
];

Widget _page(String label, GoRouterState state) {
  final id = state.pathParameters['id'];
  return Scaffold(body: Text('$label $id'));
}

Widget _app() => MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/learn',
        routes: [
          GoRoute(path: '/learn', builder: (_, __) => const LearnScreen()),
          GoRoute(
            path: '/player/:id',
            builder: (_, s) => _page('PLAYER', s),
          ),
          GoRoute(
            path: '/course/:id',
            builder: (_, s) => _page('COURSE', s),
          ),
          GoRoute(
            path: '/explore',
            builder: (_, __) => const Scaffold(body: Text('EXPLORE PAGE')),
          ),
        ],
      ),
    );

Future<void> _pump(WidgetTester t) async {
  useViewport(t, mobileSize);
  await t.pumpWidget(_app());
  await t.pumpAndSettle();
}

void main() {
  tearDown(AppDependencies.reset);

  test('enrolledFromJson converts percent and picks the resume target', () {
    final row = <String, dynamic>{
      'id': 7,
      'title': 'Go',
      'progress': 62.5,
      'last_lesson_id': 55,
    };
    final started = enrolledFromJson(row, 0);
    expect(started.progress, 0.625);
    expect(started.resumeRoute, '/player/55');

    final fresh = enrolledFromJson({'id': 8, 'progress': 0}, 1);
    expect(fresh.resumeRoute, '/course/8');

    final odd = enrolledFromJson({'id': 9, 'progress': 400}, 2);
    expect(odd.progress, 1.0);
  });

  test('ApiLearnRepository reads the /me/courses array', () async {
    final adapter = _FakeAdapter(
      '[{"id":7,"title":"Go","progress":62,"last_lesson_id":55},'
      '{"id":8,"title":"Flutter","progress":100}]',
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
      ..httpClientAdapter = adapter;
    final repo = ApiLearnRepository(
      RestClient(tokenStore: MemoryTokenStore(), dio: dio),
    );

    final list = await repo.enrolled();

    expect(list.map((c) => c.title), ['Go', 'Flutter']);
    expect(list[1].progress, 1.0);
    expect(adapter.requests.single.path, '/me/courses');
  });

  testWidgets('lists the learner courses with progress', (t) async {
    AppDependencies.learnRepository = _FakeLearn(_two);
    await _pump(t);
    expect(find.text('Go เบื้องต้น'), findsOneWidget);
    expect(find.text('62% เสร็จแล้ว'), findsOneWidget);
    expect(find.text('0% เสร็จแล้ว'), findsOneWidget);
  });

  testWidgets('continue opens the lesson the learner stopped at', (t) async {
    AppDependencies.learnRepository = _FakeLearn(_two);
    await _pump(t);
    await t.tap(find.text('Go เบื้องต้น'));
    await t.pumpAndSettle();
    expect(find.text('PLAYER 55'), findsOneWidget);
  });

  testWidgets('a course never opened goes to its page', (t) async {
    AppDependencies.learnRepository = _FakeLearn(_two);
    await _pump(t);
    await t.tap(find.text('Flutter จริงจัง'));
    await t.pumpAndSettle();
    expect(find.text('COURSE 8'), findsOneWidget);
  });

  testWidgets('empty state links to Explore', (t) async {
    AppDependencies.learnRepository = _FakeLearn(const []);
    await _pump(t);
    expect(find.text('ยังไม่มีคอร์สที่ลงทะเบียน'), findsOneWidget);
    await t.tap(find.text('เลือกคอร์ส'));
    await t.pumpAndSettle();
    expect(find.text('EXPLORE PAGE'), findsOneWidget);
  });

  testWidgets('error state has a working retry', (t) async {
    AppDependencies.learnRepository = _FakeLearn(_two, failLoads: 1);
    await _pump(t);
    expect(find.text('โหลดคอร์สของคุณไม่สำเร็จ'), findsOneWidget);
    await t.tap(find.text('ลองใหม่'));
    await t.pumpAndSettle();
    expect(find.text('Go เบื้องต้น'), findsOneWidget);
  });
}
