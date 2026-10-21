import 'package:ab_learning_app/core/widgets/app_bottom_nav.dart';
import 'package:ab_learning_app/core/widgets/app_button.dart';
import 'package:ab_learning_app/core/widgets/app_chip.dart';
import 'package:ab_learning_app/core/widgets/app_progress_bar.dart';
import 'package:ab_learning_app/core/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('primary calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(AppButton.primary(label: 'Go', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('is disabled and shows a spinner while loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          AppButton.primary(
            label: 'Go',
            onPressed: () => taps++,
            loading: true,
          ),
        ),
      );
      expect(find.text('Go'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      expect(taps, 0);
    });
  });

  testWidgets('AppChip reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(AppChip(label: 'AI', onTap: () => taps++)),
    );
    await tester.tap(find.text('AI'));
    expect(taps, 1);
  });

  testWidgets('StatusPill renders its label', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatusPill(label: '-40%', variant: StatusPillVariant.error)),
    );
    expect(find.text('-40%'), findsOneWidget);
  });

  testWidgets('AppProgressBar clamps its value to 0..1', (tester) async {
    await tester.pumpWidget(_wrap(const AppProgressBar(value: 1.5)));
    final box = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(box.widthFactor, 1.0);
  });

  testWidgets('AppBottomNav reports the tapped index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(onTap: (i) => tapped = i),
        ),
      ),
    );
    await tester.tap(find.text('Profile'));
    expect(tapped, 4);
  });
}
