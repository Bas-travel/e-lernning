import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_models.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_repository.dart';
import 'package:ab_learning_app/features/course/presentation/hifi_course_detail_screen.dart';
import 'package:ab_learning_app/features/course/presentation/hifi_video_player_screen.dart';
import 'package:ab_learning_app/features/home/models/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_helpers.dart';

/// A catalog that "has" course 7 / lessons 11 and 12, and records progress.
class _FakeCatalog implements CatalogRepository {
  final saved = <String>[];
  bool acceptProgress = true;

  @override
  bool get bundledOnly => false;

  @override
  Future<HomeFeed?> homeFeed() async => null;

  @override
  Future<CatalogCourse?> course(String id) async => id == '7'
      ? const CatalogCourse(
          id: 7,
          title: 'Server Course',
          price: 1000,
          instructorName: 'Dr. Krit',
        )
      : null;

  @override
  Future<List<CatalogSection>?> curriculum(String courseId) async => const [
        CatalogSection(
          id: 1,
          title: 'Intro',
          lessons: [
            CatalogLesson(
              id: 11,
              title: 'Server Lesson One',
              durationSeconds: 90,
              isPreview: true,
            ),
            CatalogLesson(
              id: 12,
              title: 'Server Lesson Two',
              durationSeconds: 60,
              isPreview: true,
            ),
          ],
        ),
      ];

  @override
  Future<LessonDetail?> lesson(String id) async => switch (id) {
        '11' => const LessonDetail(
            id: 11,
            courseId: 7,
            title: 'Server Lesson One',
            durationSeconds: 90,
          ),
        '12' => const LessonDetail(
            id: 12,
            courseId: 7,
            title: 'Server Lesson Two',
            durationSeconds: 60,
          ),
        _ => null,
      };

  @override
  Future<bool> saveProgress(
    String lessonId, {
    required int watchedSeconds,
    required String status,
  }) async {
    saved.add('$lessonId:$status:$watchedSeconds');
    return acceptProgress;
  }
}

Widget _app(String initial) => MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: initial,
        routes: [
          GoRoute(
            path: '/course/:id',
            builder: (_, s) =>
                HifiCourseDetailScreen(courseId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: '/player/:id',
            builder: (_, s) =>
                HifiVideoPlayerScreen(lessonId: s.pathParameters['id']!),
          ),
        ],
      ),
    );

void main() {
  installMockAuth();

  late _FakeCatalog catalog;
  setUp(() {
    catalog = _FakeCatalog();
    AppDependencies.catalogRepository = catalog;
  });

  group('Course detail', () {
    testWidgets('a numeric id shows the server course', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/course/7'));
      await tester.pumpAndSettle();

      expect(find.text('Server Course'), findsOneWidget);
      expect(find.text('Go Backend Professional'), findsNothing);
      expect(find.textContaining('Server Lesson One'), findsOneWidget);
      expect(find.textContaining('฿1,000'), findsWidgets);
    });

    testWidgets('an unknown id falls back to the sample', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/course/go-backend'));
      await tester.pumpAndSettle();

      expect(find.text('Go Backend Professional'), findsOneWidget);
    });
  });

  group('Video player', () {
    testWidgets('a numeric id shows the server lesson', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/player/11'));
      await tester.pumpAndSettle();

      expect(find.text('Server Lesson One'), findsWidgets);
      expect(find.textContaining('Server Lesson Two'), findsWidgets);
    });

    testWidgets('next saves progress, then opens the next lesson',
        (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/player/11'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('บทเรียนถัดไป'));
      await tester.pumpAndSettle();

      expect(catalog.saved, ['11:completed:90']);
      expect(find.text('Server Lesson Two'), findsWidgets);
    });

    testWidgets('the last lesson completes the course', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/player/12'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('บทเรียนถัดไป'));
      await tester.pumpAndSettle();

      expect(catalog.saved, ['12:completed:60']);
      expect(find.text('เรียนครบทุกบทแล้ว!'), findsOneWidget);
    });

    testWidgets('a rejected save warns but still moves on', (tester) async {
      catalog.acceptProgress = false;
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/player/11'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('บทเรียนถัดไป'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('บันทึกความคืบหน้าไม่สำเร็จ'), findsOneWidget);
    });
  });
}
