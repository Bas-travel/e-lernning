
import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/features/learn/presentation/learn_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_helpers.dart';

Widget _router(String initial) {
  return MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/learn',
          builder: (_, __) => const LearnScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Scaffold(
            body: Text('LOGIN PAGE'),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(
            body: Text('HOME PAGE'),
          ),
        ),
        GoRoute(
          path: '/explore',
          builder: (_, __) => const Scaffold(
            body: Text('EXPLORE PAGE'),
          ),
        ),
        GoRoute(
          path: '/player/:id',
          builder: (_, state) => Scaffold(
            body: Text('PLAYER ${state.pathParameters['id']}'),
          ),
        ),
      ],
    ),
  );
}

void main() {
  installMockAuth();

  testWidgets('profile falls back to demo data when signed out',
      (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(_router('/profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Anan Suksawat'), findsOneWidget);
    expect(find.text('learner@ablearning.com'), findsOneWidget);
  });


testWidgets('profile shows the signed-in user', (tester) async {
  useViewport(tester, mobileSize);

  final repository = AppDependencies.authRepository;


  final loginFuture = repository.login(
    identifier: 'real@user.test',
    password: 'pw',
  );

  await tester.pump(const Duration(milliseconds: 300));

  final session = await loginFuture;

  expect(session.user?.email, 'real@user.test');

  await tester.pumpWidget(_router('/profile'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));

  expect(find.text('real@user.test'), findsNWidgets(2));

});


  testWidgets('logout clears the session and opens login', (tester) async {
    useViewport(tester, mobileSize);

    final loginFuture = AppDependencies.authRepository.login(
      identifier: 'real@user.test',
      password: 'pw',
    );

    await tester.pump(const Duration(milliseconds: 1));
    await loginFuture;

    await tester.pumpWidget(_router('/profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final logout = find.text('Logout');
    expect(logout, findsWidgets);

    await tester.ensureVisible(logout.first);
    await tester.tap(logout.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('LOGIN PAGE'), findsOneWidget);
    expect(await AppDependencies.authRepository.hasSession(), isFalse);
  });

  testWidgets('profile "My Courses" opens the learning list',
      (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(_router('/profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final myCourses = find.text('My Courses');
    await tester.ensureVisible(myCourses.first);
    await tester.tap(myCourses.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('My Learning'), findsOneWidget);
  });

  testWidgets('learn lists enrolled courses and resumes a lesson',
      (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(_router('/learn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('My Learning'), findsOneWidget);
    expect(find.text('Go Backend Masterclass'), findsOneWidget);
    expect(find.text('68% เสร็จแล้ว'), findsOneWidget);

    await tester.tap(find.text('Go Backend Masterclass'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('PLAYER lesson1'), findsOneWidget);
  });

  testWidgets('bottom navigation moves between tabs', (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(_router('/learn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Explore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('EXPLORE PAGE'), findsOneWidget);
  });
}