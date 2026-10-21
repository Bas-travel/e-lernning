import 'package:ab_learning_app/app.dart';
import 'package:ab_learning_app/features/course/presentation/course_detail_screen.dart';
import 'package:ab_learning_app/features/course/presentation/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void _useMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('splash -> onboarding -> login -> home', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const App());
    expect(find.text('AB LEARNING'), findsOneWidget);

    // Splash waits one second before routing to onboarding.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'learner@example.com');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.textContaining('สวัสดี'), findsOneWidget);
  });

  testWidgets('onboarding Skip goes to login', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const App());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('course detail shows price and curriculum', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(home: CourseDetailScreen(courseId: 'go-backend')),
    );
    expect(find.text('Go Backend Professional'), findsOneWidget);
    expect(find.text('฿2,990'), findsOneWidget);
    expect(find.textContaining('Introduction'), findsOneWidget);
  });

  testWidgets('video player switches tabs', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(home: VideoPlayerScreen(lessonId: 'lesson1')),
    );
    expect(find.textContaining('slides-rest-api.pdf'), findsOneWidget);

    await tester.tap(find.text('Notes'));
    await tester.pump();
    expect(find.textContaining('slides-rest-api.pdf'), findsNothing);
  });
}
