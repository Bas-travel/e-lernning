import 'dart:typed_data';

import 'package:ab_learning_app/core/network/rest_client.dart';
import 'package:ab_learning_app/core/network/token_store.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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

ResponseBody _json(String body, [int status = 200]) {
  return ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

({ApiCatalogRepository repo, _FakeAdapter adapter}) _setup(
  ResponseBody Function(RequestOptions) handler,
) {
  final adapter = _FakeAdapter(handler);
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter;
  final client = RestClient(tokenStore: MemoryTokenStore(), dio: dio);
  return (repo: ApiCatalogRepository(client), adapter: adapter);
}

void main() {
  group('ApiCatalogRepository', () {
    test('parses a course with its instructor', () async {
      final t = _setup(
        (_) => _json(
          '{"id":3,"title":"Go","description":"d","price":2000,'
          '"discount_price":1500,"rating_avg":4.8,"student_count":10,'
          '"level":"beginner","category":"Dev",'
          '"instructor":{"id":9,"display_name":"Nok"}}',
        ),
      );

      final course = await t.repo.course('3');

      expect(t.adapter.requests.single.path, '/courses/3');
      expect(course!.title, 'Go');
      expect(course.instructorName, 'Nok');
      expect(course.effectivePrice, 1500);
      expect(course.studentCount, 10);
    });

    test('parses the curriculum into sections and lessons', () async {
      final t = _setup(
        (_) => _json(
          '[{"id":1,"title":"Intro","lessons":['
          '{"id":11,"title":"Hello","duration_seconds":125,'
          '"is_preview":true,"video_url":""},'
          '{"id":12,"title":"Setup","type":"quiz"}]}]',
        ),
      );

      final sections = await t.repo.curriculum('3');

      expect(sections!.single.lessons, hasLength(2));
      final first = sections.single.lessons.first;
      expect(first.durationLabel, '2:05');
      expect(first.isPreview, isTrue);
      expect(first.videoUrl, isNull);
      expect(sections.single.lessons.last.type, 'quiz');
    });

    test('parses a lesson with progress', () async {
      final t = _setup(
        (_) => _json(
          '{"id":11,"course_id":3,"title":"Hello","section_title":"Intro",'
          '"status":"completed","watched_seconds":120,'
          '"video_url":"https://v/1.mp4"}',
        ),
      );

      final lesson = await t.repo.lesson('11');

      expect(lesson!.courseId, 3);
      expect(lesson.isCompleted, isTrue);
      expect(lesson.videoUrl, 'https://v/1.mp4');
    });

    test('parses the home feed', () async {
      final t = _setup(
        (_) => _json(
          '{"greeting_name":"Anan","career_path_progress_pct":78,'
          '"continue_learning":[{"id":1,"title":"Go","progress_pct":68}],'
          '"recommended":[],"live":[]}',
        ),
      );

      final feed = await t.repo.homeFeed();

      expect(t.adapter.requests.single.path, '/home');
      expect(feed!.greetingName, 'Anan');
      expect(feed.continueLearning.single.progressPct, 68);
      expect(feed.careerPathProgressPct, 78);
    });

    test('slug ids never reach the network', () async {
      final t = _setup((_) => _json('{}'));

      expect(await t.repo.course('go-backend'), isNull);
      expect(await t.repo.curriculum('go-backend'), isNull);
      expect(await t.repo.lesson('lesson1'), isNull);
      expect(
        await t.repo.saveProgress(
          'lesson1',
          watchedSeconds: 5,
          status: 'in_progress',
        ),
        isFalse,
      );
      expect(t.adapter.requests, isEmpty);
    });

    test('a 404 or 500 means "not available", not an exception', () async {
      final missing = _setup((_) => _json('{"error":"nope"}', 404));
      final broken = _setup((_) => _json('{"error":"boom"}', 500));

      expect(await missing.repo.course('3'), isNull);
      expect(await broken.repo.homeFeed(), isNull);
    });

    test('a malformed body means "not available"', () async {
      final t = _setup((_) => _json('[1,2,3]'));

      expect(await t.repo.course('3'), isNull);
    });

    test('saveProgress posts the watched seconds and status', () async {
      final t = _setup((_) => _json('{}'));

      final ok = await t.repo.saveProgress(
        '11',
        watchedSeconds: 42,
        status: 'in_progress',
      );

      expect(ok, isTrue);
      expect(t.adapter.requests.single.path, '/lessons/11/progress');
      expect(
        t.adapter.requests.single.data,
        {'watched_seconds': 42, 'status': 'in_progress'},
      );
    });

    test('saveProgress reports a rejected request', () async {
      final t = _setup((_) => _json('{"error":"x"}', 403));

      final ok = await t.repo.saveProgress(
        '11',
        watchedSeconds: 1,
        status: 'completed',
      );

      expect(ok, isFalse);
    });
  });

  test('OfflineCatalogRepository has nothing to offer', () async {
    const repo = OfflineCatalogRepository();

    expect(await repo.homeFeed(), isNull);
    expect(await repo.course('1'), isNull);
    expect(await repo.curriculum('1'), isNull);
    expect(await repo.lesson('1'), isNull);
  });
}
