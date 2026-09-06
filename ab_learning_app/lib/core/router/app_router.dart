import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/video_player_screen.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
        GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/course/:id', builder: (c, s) {
          final id = c.params['id'] ?? '';
          return CourseDetailScreen(courseId: id);
        }),
        GoRoute(path: '/player/:id', builder: (c, s) {
          final id = c.params['id'] ?? '';
          return VideoPlayerScreen(lessonId: id);
        }),
      ],
    );
  }
}
