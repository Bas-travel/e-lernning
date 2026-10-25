import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/interests_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/video_player_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/explore/presentation/search_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/profile/presentation/certificates_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/help_center_screen.dart';
import '../../features/profile/presentation/portfolio_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/wallet_screen.dart';
import '../../features/tutor/presentation/ai_tutor_screen.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(
          path: '/otp',
          builder: (context, state) => OtpScreen(
            args: state.extra is OtpArgs ? state.extra as OtpArgs : null,
          ),
        ),
        GoRoute(path: '/interests', builder: (context, state) => const InterestsScreen()),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
        GoRoute(
          path: '/search',
          builder: (context, state) =>
              SearchScreen(initialQuery: state.queryParameters['q'] ?? ''),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/community', builder: (context, state) => const CommunityScreen()),
        GoRoute(path: '/tutor', builder: (context, state) => const AiTutorScreen()),
        GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
        GoRoute(path: '/certificates', builder: (context, state) => const CertificatesScreen()),
        GoRoute(path: '/portfolio', builder: (context, state) => const PortfolioScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/help', builder: (context, state) => const HelpCenterScreen()),
        GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
        GoRoute(
          path: '/checkout/:id',
          builder: (context, state) =>
              CheckoutScreen(courseId: state.pathParameters['id'] ?? ''),
        ),
        GoRoute(path: '/course/:id', builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CourseDetailScreen(courseId: id);
        }),
        GoRoute(path: '/player/:id', builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return VideoPlayerScreen(lessonId: id);
        }),
      ],
    );
  }
}
