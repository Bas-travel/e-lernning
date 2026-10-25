import 'package:ab_learning_app/app.dart';
import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AppDependencies.authRepository =
        MockAuthRepository(latency: Duration.zero);
  });

  tearDown(() {
    AppDependencies.reset();
  });

  testWidgets('app shows splash then onboarding', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('AB LEARNING'), findsOneWidget);

    // Advance through the splash timer and allow onboarding to render.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Build real skills, not just watch videos'),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
  });
}
