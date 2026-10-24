import 'package:ab_learning_app/app.dart';
import 'package:ab_learning_app/features/course/presentation/course_detail_screen.dart';
import 'package:ab_learning_app/features/course/presentation/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  installMockAuth();

  testWidgets('splash -> onboarding -> login -> home', (tester) async {
    useViewport(tester, mobileSize);

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

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'learner@example.com');
    await tester.enterText(fields.at(1), 'secret');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.textContaining('สวัสดี'), findsOneWidget);
  });

  testWidgets('login shows an error banner for empty credentials',
      (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(const App());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.textContaining('กรุณากรอก'), findsOneWidget);
    expect(find.textContaining('สวัสดี'), findsNothing);
  });

  testWidgets('onboarding Skip goes to login', (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(const App());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('course detail shows price and curriculum', (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(
      const MaterialApp(home: CourseDetailScreen(courseId: 'go-backend')),
    );
    expect(find.text('Go Backend Professional'), findsOneWidget);
    expect(find.text('฿2,990'), findsOneWidget);
    expect(find.textContaining('Introduction'), findsOneWidget);
  });

  testWidgets('video player switches tabs', (tester) async {
    useViewport(tester, mobileSize);

    await tester.pumpWidget(
      const MaterialApp(home: VideoPlayerScreen(lessonId: 'lesson1')),
    );
    expect(find.textContaining('slides-rest-api.pdf'), findsOneWidget);

    await tester.tap(find.text('Notes'));
    await tester.pump();
    expect(find.textContaining('slides-rest-api.pdf'), findsNothing);
  });
}
