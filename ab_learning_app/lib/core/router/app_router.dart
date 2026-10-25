import '../../features/auth/presentation/register_screen.dart';
import 'package:go_router/go_router.dart';
// <<<<<<< design/tokens-update
// import '../../features/auth/presentation/splash_screen.dart';
// import '../../features/auth/presentation/onboarding_screen.dart';
// import '../../features/auth/presentation/login_screen.dart';
// import '../../features/home/presentation/home_screen.dart';
// import '../../features/course/presentation/course_catalog_screen.dart';
// import '../../features/course/presentation/course_detail_screen.dart';
// import '../../features/course/presentation/video_player_screen.dart';
// import '../../features/course/presentation/quiz_screen.dart';
// import '../../features/course/presentation/quiz_result_screen.dart';
// import '../../features/course/presentation/certificate_screen.dart';
// import '../../features/future/presentation/future_workspace_screen.dart';
// =======
// import '../../features/auth/presentation/forgot_password_screen.dart';
// import '../../features/auth/presentation/interests_screen.dart';
// import '../../features/auth/presentation/login_screen.dart';
// import '../../features/auth/presentation/onboarding_screen.dart';
// import '../../features/auth/presentation/otp_screen.dart';
// import '../../features/auth/presentation/register_screen.dart';
// import '../../features/auth/presentation/splash_screen.dart';
// import '../../features/checkout/presentation/checkout_screen.dart';
// import '../../features/community/presentation/community_screen.dart';
// import '../../features/course/presentation/course_detail_screen.dart';
// import '../../features/course/presentation/video_player_screen.dart';
// import '../../features/explore/presentation/explore_screen.dart';
// import '../../features/explore/presentation/search_screen.dart';
// import '../../features/home/presentation/home_screen.dart';
// import '../../features/learn/presentation/learn_screen.dart';
// import '../../features/profile/presentation/certificates_screen.dart';
// import '../../features/profile/presentation/edit_profile_screen.dart';
// import '../../features/profile/presentation/help_center_screen.dart';
// import '../../features/profile/presentation/portfolio_screen.dart';
// import '../../features/profile/presentation/profile_screen.dart';
// import '../../features/profile/presentation/settings_screen.dart';
// import '../../features/profile/presentation/wallet_screen.dart';
// import '../../features/tutor/presentation/ai_tutor_screen.dart';
// >>>>>>> main

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
// <<<<<<< design/tokens-update
//         GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
//         GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
//         GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
//         // GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
//         GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
//         GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
//         GoRoute(path: '/courses', builder: (c, s) => const CourseCatalogScreen()),
//         GoRoute(path: '/course/:id', builder: (c, s) {
//           final id = s.pathParameters['id'] ?? '';
// =======
//         GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
//         GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
//         GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
//         GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
//         GoRoute(
//           path: '/otp',
//           builder: (context, state) => OtpScreen(
//             args: state.extra is OtpArgs ? state.extra as OtpArgs : null,
//           ),
//         ),
//         GoRoute(path: '/interests', builder: (context, state) => const InterestsScreen()),
//         GoRoute(
//           path: '/forgot-password',
//           builder: (context, state) => const ForgotPasswordScreen(),
//         ),
//         GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
//         GoRoute(
//           path: '/search',
//           builder: (context, state) =>
//               SearchScreen(initialQuery: state.queryParameters['q'] ?? ''),
//         ),
//         GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
//         GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
//         GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
//         GoRoute(path: '/community', builder: (context, state) => const CommunityScreen()),
//         GoRoute(path: '/tutor', builder: (context, state) => const AiTutorScreen()),
//         GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
//         GoRoute(path: '/certificates', builder: (context, state) => const CertificatesScreen()),
//         GoRoute(path: '/portfolio', builder: (context, state) => const PortfolioScreen()),
//         GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
//         GoRoute(path: '/help', builder: (context, state) => const HelpCenterScreen()),
//         GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
//         GoRoute(
//           path: '/checkout/:id',
//           builder: (context, state) =>
//               CheckoutScreen(courseId: state.pathParameters['id'] ?? ''),
//         ),
//         GoRoute(path: '/course/:id', builder: (context, state) {
//           final id = state.pathParameters['id'] ?? '';
// >>>>>>> main
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
        //เพิ่มปุ่มสำหรับการนำทางไปยังหน้าต่างๆ ของ FutureWorkspaceScreen 3 ปุ่ม
        GoRoute(path: '/my-learning', builder: (c, s) => const FutureWorkspaceScreen(area: 'my-learning')),
        GoRoute(path: '/live', builder: (c, s) => const FutureWorkspaceScreen(area: 'live')),
        GoRoute(path: '/community', builder: (c, s) => const FutureWorkspaceScreen(area: 'community')),
        GoRoute(path: '/portfolio', builder: (c, s) => const FutureWorkspaceScreen(area: 'portfolio')),
        GoRoute(path: '/jobs', builder: (c, s) => const FutureWorkspaceScreen(area: 'jobs')),
        GoRoute(path: '/corporate', builder: (c, s) => const FutureWorkspaceScreen(area: 'corporate')),
        GoRoute(path: '/admin', builder: (c, s) => const FutureWorkspaceScreen(area: 'admin')),
      ],
    );
  }
}
