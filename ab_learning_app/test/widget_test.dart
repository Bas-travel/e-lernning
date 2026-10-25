import 'package:ab_learning_app/app.dart';
import 'package:ab_learning_app/features/auth/presentation/onboarding_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  installMockAuth();

  testWidgets('app renders its splash, then the onboarding slides',
      (WidgetTester tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(const App());
    expect(find.text('AB LEARNING'), findsWidgets);

    // Signed out (mock repository): the splash routes to onboarding.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
