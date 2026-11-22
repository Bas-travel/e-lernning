import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_models.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_repository.dart';
import 'package:ab_learning_app/features/home/models/home_feed.dart';
import 'package:ab_learning_app/features/home/presentation/hifi_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_helpers.dart';

/// Counts how often Home asks the server for its feed.
class _CountingCatalog implements CatalogRepository {
  int homeCalls = 0;

  @override
  bool get bundledOnly => false;

  @override
  Future<HomeFeed?> homeFeed() async {
    homeCalls++;
    return null;
  }

  @override
  Future<CatalogCourse?> course(String id) async => null;

  @override
  Future<List<CatalogSection>?> curriculum(String courseId) async => null;

  @override
  Future<LessonDetail?> lesson(String id) async => null;

  @override
  Future<bool> saveProgress(
    String lessonId, {
    required int watchedSeconds,
    required String status,
  }) async =>
      false;
}

void main() {
  installMockAuth();

  testWidgets('switching tabs keeps Home alive and does not refetch',
      (tester) async {
    final catalog = _CountingCatalog();
    AppDependencies.catalogRepository = catalog;
    useViewport(tester, mobileSize);

    // Same structure as the learner tabs in AppRouter.
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => shell,
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HifiHomeScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/explore',
                builder: (_, __) => const Scaffold(body: Text('EXPLORE TAB')),
              ),
            ]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(catalog.homeCalls, 1);

    router.go('/explore');
    await tester.pumpAndSettle();
    expect(find.text('EXPLORE TAB'), findsOneWidget);

    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.text('EXPLORE TAB'), findsNothing);
    expect(catalog.homeCalls, 1, reason: 'Home must not reload on tab switch');
  });
}
