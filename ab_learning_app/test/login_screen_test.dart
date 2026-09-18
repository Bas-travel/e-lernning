import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ab_learning_app/core/router/app_router.dart';
import 'package:ab_learning_app/core/theme/app_theme.dart';

void main() {
  testWidgets('Login screen renders and shows validation errors on empty submit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final GoRouter router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AB LEARNING'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    // Clear the pre-filled fields then attempt submit.
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Required'), findsWidgets);
  });

  testWidgets('Login with seed credentials navigates to Home',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final GoRouter router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fields are pre-filled with the mock seed account in this scaffold.
    await tester.tap(find.text('Log in'));
    await tester.pump(); // start loading
    await tester.pump(const Duration(milliseconds: 800)); // mock latency
    await tester.pumpAndSettle();

    expect(find.text('AB LEARNING'), findsNothing);
  });
}
