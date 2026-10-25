import 'package:ab_learning_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/interests_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/login_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/onboarding_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/otp_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/register_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/splash_screen.dart';
import 'package:ab_learning_app/features/course/presentation/course_detail_screen.dart';
import 'package:ab_learning_app/features/course/presentation/video_player_screen.dart';
import 'package:ab_learning_app/features/explore/presentation/explore_screen.dart';
import 'package:ab_learning_app/features/explore/presentation/search_screen.dart';
import 'package:ab_learning_app/features/home/presentation/home_screen.dart';
import 'package:ab_learning_app/features/learn/presentation/learn_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

/// Renders each screen at desktop width. A layout overflow or build error in
/// the desktop branch fails the test.
void main() {
  installMockAuth();

  final screens = <String, Widget Function()>{
    'splash': () => const SplashScreen(),
    'onboarding': () => const OnboardingScreen(),
    'login': () => const LoginScreen(),
    'register': () => const RegisterScreen(),
    'otp': () => const OtpScreen(),
    'interests': () => const InterestsScreen(),
    'forgot password': () => const ForgotPasswordScreen(),
    'home': () => const HomeScreen(),
    'explore': () => const ExploreScreen(),
    'search': () => const SearchScreen(initialQuery: 'flutter'),
    'course detail': () => const CourseDetailScreen(courseId: 'go-backend'),
    'video player': () => const VideoPlayerScreen(lessonId: 'lesson1'),
    'learn': () => const LearnScreen(),
    'profile': () => const ProfileScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} renders at desktop width', (tester) async {
      useViewport(tester, desktopSize);

      await tester.pumpWidget(MaterialApp(home: entry.value()));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(Scaffold), findsWidgets);

      // Dispose the tree so timers started by the screen are cancelled.
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('onboarding advances through slides on desktop', (tester) async {
    useViewport(tester, desktopSize);

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('interests toggles chips on desktop', (tester) async {
    useViewport(tester, desktopSize);

    await tester.pumpWidget(const MaterialApp(home: InterestsScreen()));
    await tester.tap(find.text('Data'));
    await tester.tap(find.text('Advanced'));
    await tester.tap(find.text('Upskill'));
    await tester.pump();
    expect(find.text('Start Learning'), findsOneWidget);
  });
}
