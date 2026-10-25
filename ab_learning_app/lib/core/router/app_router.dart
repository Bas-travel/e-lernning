
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/interests_screen.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/explore/presentation/search_screen.dart';

import '../../features/learn/presentation/learn_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/wallet_screen.dart';
import '../../features/profile/presentation/certificates_screen.dart';
import '../../features/profile/presentation/portfolio_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/help_center_screen.dart';

import '../../features/tutor/presentation/ai_tutor_screen.dart';

import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/video_player_screen.dart';
import '../../features/course/presentation/quiz_screen.dart';
import '../../features/course/presentation/quiz_result_screen.dart';
import '../../features/course/presentation/certificate_screen.dart';

import '../../features/future/presentation/future_workspace_screen.dart';

class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      // Authentication
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => OtpScreen(
          args: state.extra is OtpArgs
              ? state.extra as OtpArgs
              : null,
        ),
      ),
      GoRoute(
        path: '/interests',
        builder: (context, state) => const InterestsScreen(),
      ),

      // Main navigation
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/learn',
        builder: (context, state) => const LearnScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => SearchScreen(
          initialQuery: state.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: '/my-learning',
        builder: (context, state) => const LearnScreen(),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Profile and account menus
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/certificates',
        builder: (context, state) => const CertificatesScreen(),
      ),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpCenterScreen(),
      ),

      // AI Tutor: support both existing route names
      GoRoute(
        path: '/ai-tutor',
        builder: (context, state) => const AiTutorScreen(),
      ),
      GoRoute(
        path: '/tutor',
        builder: (context, state) => const AiTutorScreen(),
      ),

      // Courses and learning activities
      GoRoute(
        path: '/course/:id',
        builder: (context, state) => CourseDetailScreen(
          courseId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) => VideoPlayerScreen(
          lessonId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) => QuizScreen(
          quizId: state.pathParameters['id'] ?? 'q001',
        ),
      ),
      GoRoute(
        path: '/quiz-result',
        builder: (context, state) {
          final score =
              int.tryParse(state.queryParameters['score'] ?? '0') ?? 0;
          final total =
              int.tryParse(state.queryParameters['total'] ?? '1') ?? 1;
          final percentage =
              int.tryParse(state.queryParameters['percentage'] ?? '0') ?? 0;

          return QuizResultScreen(
            score: score,
            total: total,
            percentage: percentage,
          );
        },
      ),
      GoRoute(
        path: '/certificate/:courseName',
        builder: (context, state) {
          final courseName =
              state.pathParameters['courseName'] ?? 'Course';

          return CertificateScreen(
            courseName: courseName.replaceAll('-', ' '),
          );
        },
      ),

      // Existing feature workspaces
      GoRoute(
        path: '/skill-assessment',
        builder: (context, state) =>
            const FutureWorkspaceScreen(area: 'assessment'),
      ),
      GoRoute(
        path: '/career-path',
        builder: (context, state) =>
            const FutureWorkspaceScreen(area: 'career'),
      ),
      GoRoute(
        path: '/live',
        builder: (context, state) =>
            const FutureWorkspaceScreen(area: 'live'),
      ),
      GoRoute(
        path: '/jobs',
        builder: (context, state) =>
            const FutureWorkspaceScreen(area: 'jobs'),
      ),
      GoRoute(
        path: '/corporate',
        builder: (context, state) =>
            const FutureWorkspaceScreen(area: 'corporate'),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) =>
            const FutureWorkspaceScreen(area: 'admin'),
      ),
    ],
  );
}
