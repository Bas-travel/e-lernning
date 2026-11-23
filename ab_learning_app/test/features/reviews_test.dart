import 'dart:typed_data';

import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/core/network/rest_client.dart';
import 'package:ab_learning_app/core/network/token_store.dart';
import 'package:ab_learning_app/features/reviews/data/reviews_repository.dart';
import 'package:ab_learning_app/features/reviews/presentation/course_reviews_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body, [int status = 200]) => ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class _FakeReviews implements ReviewsRepository {
  _FakeReviews(this.page, {this.failLoads = 0, this.result});

  ReviewsPage page;
  int failLoads;
  ReviewSubmitResult? result;
  final List<(int, String)> submitted = [];

  @override
  bool get bundledOnly => false;

  @override
  Future<ReviewsPage> list(String courseId) async {
    if (failLoads > 0) {
      failLoads--;
      throw Exception('offline');
    }
    return page;
  }

  @override
  Future<ReviewSubmitResult> submit(
    String courseId, {
    required int rating,
    required String comment,
  }) async {
    submitted.add((rating, comment));
    return result ?? ReviewSubmitResult.saved;
  }
}

const _someReviews = ReviewsPage(
  average: 4.5,
  count: 2,
  items: [
    CourseReview(
      id: 2,
      rating: 4,
      comment: 'เนื้อหาดีมาก',
      author: 'สมชาย ใจดี',
      mine: false,
      date: '1 พ.ย. 2026',
    ),
    CourseReview(
      id: 1,
      rating: 5,
      comment: 'ชอบมาก',
      author: 'ผู้เรียน',
      mine: true,
      date: '2 พ.ย. 2026',
    ),
  ],
);

Future<void> _pump(WidgetTester tester) async {
  useViewport(tester, mobileSize);
  await tester.pumpWidget(
    const MaterialApp(home: CourseReviewsScreen(courseId: '7')),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester t, Finder finder) async {
  await t.ensureVisible(finder);
  await t.pumpAndSettle();
  await t.tap(finder);
}

void main() {
  tearDown(AppDependencies.reset);

  test('ApiReviewsRepository parses the page and maps refusals', () async {
    var status = 200;
    final adapter = _FakeAdapter((o) {
      if (o.method == 'GET') {
        return _json(
          '{"items":[{"id":1,"rating":5,"comment":"ok","author":"A",'
          '"mine":true,"created_at":"2026-11-02T10:00:00Z"}],'
          '"rating_avg":5,"rating_count":1}',
        );
      }
      return _json('{"ok":true}', status);
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
      ..httpClientAdapter = adapter;
    final repo = ApiReviewsRepository(
      RestClient(tokenStore: MemoryTokenStore(), dio: dio),
    );

    final page = await repo.list('7');
    expect(page.count, 1);
    expect(page.mine?.rating, 5);
    expect(adapter.requests.single.path, '/courses/7/reviews');

    expect(
      await repo.submit('7', rating: 4, comment: 'x'),
      ReviewSubmitResult.saved,
    );
    expect(adapter.requests.last.data, {'rating': 4, 'comment': 'x'});
    status = 403;
    expect(
      await repo.submit('7', rating: 4, comment: ''),
      ReviewSubmitResult.notEnrolled,
    );
    status = 400;
    expect(
      await repo.submit('7', rating: 4, comment: ''),
      ReviewSubmitResult.invalid,
    );
    status = 500;
    expect(
      await repo.submit('7', rating: 4, comment: ''),
      ReviewSubmitResult.failed,
    );
  });

  testWidgets('shows the empty state and keeps submit disabled', (t) async {
    AppDependencies.reviewsRepository = _FakeReviews(ReviewsPage.empty);
    await _pump(t);
    expect(find.text('ยังไม่มีคะแนน'), findsOneWidget);
    expect(find.textContaining('เป็นคนแรก'), findsOneWidget);
    final send = find.widgetWithText(ElevatedButton, 'ส่งรีวิว');
    expect(t.widget<ElevatedButton>(send).onPressed, isNull);
  });

  testWidgets('lists reviews and pre-fills the learner own review', (t) async {
    AppDependencies.reviewsRepository = _FakeReviews(_someReviews);
    await _pump(t);
    expect(find.text('4.5 / 5 (2 รีวิว)'), findsOneWidget);
    expect(find.text('เนื้อหาดีมาก'), findsOneWidget);
    expect(find.text('ผู้เรียน (คุณ)'), findsOneWidget);
    expect(find.text('อัปเดตรีวิว'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'ชอบมาก'), findsOneWidget);
  });

  testWidgets('sends the chosen rating and comment', (t) async {
    final repo = _FakeReviews(ReviewsPage.empty);
    AppDependencies.reviewsRepository = repo;
    await _pump(t);

    await _tap(t, find.byKey(const ValueKey('star-4')));
    await t.pump();
    await t.enterText(find.byType(TextField), 'สอนเข้าใจง่าย');
    await _tap(t, find.widgetWithText(ElevatedButton, 'ส่งรีวิว'));
    await t.pumpAndSettle();

    expect(repo.submitted.single, (4, 'สอนเข้าใจง่าย'));
    expect(find.text('บันทึกรีวิวแล้ว'), findsOneWidget);
  });

  testWidgets('explains why a non-enrolled learner cannot review', (t) async {
    final repo = _FakeReviews(
      ReviewsPage.empty,
      result: ReviewSubmitResult.notEnrolled,
    );
    AppDependencies.reviewsRepository = repo;
    await _pump(t);

    await _tap(t, find.byKey(const ValueKey('star-5')));
    await t.pump();
    await _tap(t, find.widgetWithText(ElevatedButton, 'ส่งรีวิว'));
    await t.pumpAndSettle();

    expect(find.text('รีวิวได้เฉพาะผู้ที่ลงทะเบียนคอร์สนี้'), findsOneWidget);
  });

  testWidgets('error state has a working retry', (t) async {
    AppDependencies.reviewsRepository =
        _FakeReviews(_someReviews, failLoads: 1);
    await _pump(t);
    expect(find.text('โหลดรีวิวไม่สำเร็จ'), findsOneWidget);
    await t.tap(find.text('ลองใหม่'));
    await t.pumpAndSettle();
    expect(find.text('เนื้อหาดีมาก'), findsOneWidget);
  });
}
