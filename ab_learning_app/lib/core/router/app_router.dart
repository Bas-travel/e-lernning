import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/course/presentation/course_catalog_screen.dart';
import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/video_player_screen.dart';
import '../../features/course/presentation/quiz_screen.dart';
import '../../features/course/presentation/quiz_result_screen.dart';
import '../../features/course/presentation/certificate_screen.dart';
import '../../features/future/presentation/future_workspace_screen.dart';

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
        GoRoute(path: '/courses', builder: (c, s) => const CourseCatalogScreen()),
        GoRoute(path: '/course/:id', builder: (c, s) {
          final id = s.pathParameters['id'] ?? '';
          return CourseDetailScreen(courseId: id);
        }),
        GoRoute(path: '/player/:id', builder: (c, s) {
          final id = s.pathParameters['id'] ?? '';
          return VideoPlayerScreen(lessonId: id);
        }),
        GoRoute(path: '/quiz/:id', builder: (c, s) {
          final id = s.pathParameters['id'] ?? 'q001';
          return QuizScreen(quizId: id);
        }),
        GoRoute(
          path: '/quiz-result',
          builder: (c, s) {
            final score = int.tryParse(s.queryParameters['score'] ?? '0') ?? 0;
            final total = int.tryParse(s.queryParameters['total'] ?? '1') ?? 1;
            final percentage = int.tryParse(s.queryParameters['percentage'] ?? '0') ?? 0;
            return QuizResultScreen(score: score, total: total, percentage: percentage);
          },
        ),
        GoRoute(
          path: '/certificate/:courseName',
          builder: (c, s) {
            final courseName = s.pathParameters['courseName'] ?? 'Course';
            return CertificateScreen(courseName: courseName.replaceAll('-', ' '));
          },
        ),
        GoRoute(path: '/ai-tutor', builder: (c, s) => const FutureWorkspaceScreen(area: 'ai')),
        GoRoute(path: '/skill-assessment', builder: (c, s) => const FutureWorkspaceScreen(area: 'assessment')),
        GoRoute(path: '/career-path', builder: (c, s) => const FutureWorkspaceScreen(area: 'career')),
        GoRoute(path: '/portfolio', builder: (c, s) => const FutureWorkspaceScreen(area: 'portfolio')),
        GoRoute(path: '/jobs', builder: (c, s) => const FutureWorkspaceScreen(area: 'jobs')),
        GoRoute(path: '/corporate', builder: (c, s) => const FutureWorkspaceScreen(area: 'corporate')),
        GoRoute(path: '/admin', builder: (c, s) => const FutureWorkspaceScreen(area: 'admin')),
      ],
    );
  }
}
