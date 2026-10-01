import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ab_learning_app/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('Login screen renders role options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: [
            GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
            GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue as'), findsOneWidget);
    expect(find.text('Learner'), findsOneWidget);
  });

  testWidgets('Login navigates to selected role home',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: [
            GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
            GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login as Learner'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
