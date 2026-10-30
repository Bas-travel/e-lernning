import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/current_user.dart';
import '../../data/mock/models.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_workflows.dart';
import '../../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/hifi_login_screen.dart';
import '../../features/auth/presentation/hifi_register_screen.dart';
import '../../features/auth/presentation/hifi_splash_screen.dart';
import '../../features/auth/presentation/interests_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/corporate/presentation/corporate_dashboard_screen.dart';
import '../../features/corporate/presentation/corporate_workflows.dart';
import '../../features/course/presentation/certificate_screen.dart';
import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/curriculum_screen.dart';
import '../../features/course/presentation/hifi_course_detail_screen.dart';
import '../../features/course/presentation/hifi_video_player_screen.dart';
import '../../features/course/presentation/payment_screen.dart';
import '../../features/course/presentation/video_player_screen.dart';
import '../../features/employer/presentation/employer_dashboard_screen.dart';
import '../../features/employer/presentation/employer_workflows.dart';
import '../../features/explore/presentation/hifi_explore_screen.dart';
import '../../features/explore/presentation/search_screen.dart';
import '../../features/future/presentation/future_workspace_screen.dart';
import '../../features/home/presentation/hifi_home_screen.dart';
import '../../features/instructor/presentation/instructor_course_builder_screen.dart';
import '../../features/instructor/presentation/instructor_dashboard_screen.dart';
import '../../features/instructor/presentation/instructor_revenue_screen.dart';
import '../../features/instructor/presentation/instructor_workflows.dart';
import '../../features/instructor/presentation/my_courses_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/profile/presentation/certificates_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/help_center_screen.dart';
import '../../features/profile/presentation/portfolio_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/wallet_screen.dart';
import '../../features/course/presentation/quiz_result_screen.dart'
    as classic_quiz;
import '../../features/quiz/presentation/quiz_result_screen.dart' as hifi_quiz;
import '../../features/quiz/presentation/quiz_screen.dart';
import '../../features/tutor/presentation/ai_tutor_screen.dart' as hifi_tutor;
import '../di/providers.dart';
import '../navigation/role_menus.dart';
import '../network/api_client.dart';
import '../widgets/main_shell.dart';
import '../widgets/role_scaffold.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => AppRouter(
    apiClient: ref.watch(apiClientProvider),
  ).router,
);

class AppRouter {
  late final GoRouter router;

  AppRouter({ApiClient? apiClient}) {
    router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,

      // Role-based redirect:
      // - Public authentication/onboarding routes remain accessible.
      // - Role-protected routes are redirected to the current role's home.
      // - /interests remains accessible during onboarding.
      redirect: (context, state) {
        final path = state.location;
        final requestedPrefix = _rolePrefixForPath(path);

        if (requestedPrefix == null) {
          _routerLog('Allow public route: $path');
          return null;
        }

        final rolePrefix = _rolePrefixForRole(CurrentUser.role);

        if (requestedPrefix == rolePrefix) {
          _routerLog(
            'Allow role route: path=$path, role=${CurrentUser.role}',
          );
          return null;
        }

        final destination = CurrentUser.homeRouteFor(CurrentUser.role);

        _routerLog(
          'Redirect: path=$path, '
          'requestedRole=$requestedPrefix, '
          'currentRole=${CurrentUser.role}, '
          'destination=$destination',
        );

        return destination;
      },

      routes: <RouteBase>[
        // ---------------------------------------------------------------
        // Authentication and onboarding
        // ---------------------------------------------------------------
        GoRoute(
          path: '/',
          builder: (context, state) => const HifiSplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const HifiLoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const HifiRegisterScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            _routerLog(
              'Building /otp; extra=${state.extra?.runtimeType}',
            );

            return OtpScreen(
              args: state.extra is OtpArgs ? state.extra as OtpArgs : null,
            );
          },
        ),
        GoRoute(
          path: '/interests',
          builder: (context, state) {
            _routerLog('Building /interests');
            return const InterestsScreen();
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // ---------------------------------------------------------------
        // Classic MVP screens
        // ---------------------------------------------------------------
        GoRoute(
          path: '/classic/login',
          builder: (context, state) => LoginScreen(
            authRepository:
                apiClient == null ? null : AuthRepository(apiClient: apiClient),
          ),
        ),
        GoRoute(
          path: '/classic/register',
          builder: (context, state) => RegisterScreen(
            authRepository:
                apiClient == null ? null : AuthRepository(apiClient: apiClient),
          ),
        ),
        GoRoute(
          path: '/classic/home',
          builder: (context, state) => const MainShell(),
        ),
        GoRoute(
          path: '/classic/course/:id',
          builder: (context, state) => CourseDetailScreen(
            courseId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/classic/player/:id',
          builder: (context, state) => VideoPlayerScreen(
            lessonId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/my-learning',
          builder: (context, state) => const MainShell(initialIndex: 2),
        ),

        // ---------------------------------------------------------------
        // Learner screens
        // ---------------------------------------------------------------
        GoRoute(
          path: '/home',
          builder: (context, state) => const HifiHomeScreen(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const HifiExploreScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => SearchScreen(
            initialQuery: Uri.parse(state.location).queryParameters['q'] ?? '',
          ),
        ),
        GoRoute(
          path: '/learn',
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

        // ---------------------------------------------------------------
        // Courses and learning
        // ---------------------------------------------------------------
        GoRoute(
          path: '/course/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return HifiCourseDetailScreen(courseId: id);
          },
          routes: [
            GoRoute(
              path: 'curriculum',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return CurriculumScreen(courseId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/checkout/:id',
          builder: (context, state) => PaymentScreen(
            courseId: state.pathParameters['id'] ?? '',
            courseTitle: state.extra as String?,
          ),
        ),
        GoRoute(
          path: '/checkout-demo/:id',
          builder: (context, state) => CheckoutScreen(
            courseId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/player/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return HifiVideoPlayerScreen(lessonId: id);
          },
        ),
        GoRoute(
          path: '/quiz/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return QuizScreen(lessonId: id);
          },
        ),
        GoRoute(
          path: '/quiz-result',
          builder: (context, state) {
            final extra = state.extra;

            // Hi-Fi Quiz: receives result through state.extra.
            if (extra is Map &&
                extra['result'] is QuizAttemptResult &&
                extra['questions'] is List<QuizQuestion> &&
                extra['lessonId'] is String) {
              return hifi_quiz.QuizResultScreen(
                result: extra['result'] as QuizAttemptResult,
                questions: extra['questions'] as List<QuizQuestion>,
                lessonId: extra['lessonId'] as String,
              );
            }

            // Classic Quiz: receives result through query parameters.
            final query = Uri.parse(state.location).queryParameters;

            final score = int.tryParse(query['score'] ?? '0') ?? 0;
            final total = int.tryParse(query['total'] ?? '1') ?? 1;
            final percentage = int.tryParse(query['percentage'] ?? '0') ?? 0;

            return classic_quiz.QuizResultScreen(
              score: score,
              total: total,
              percentage: percentage,
            );
          },
        ),
        GoRoute(
          path: '/tutor',
          builder: (context, state) => const hifi_tutor.HifiAiTutorScreen(),
        ),
        GoRoute(
          path: '/ai-tutor',
          builder: (context, state) => const AiTutorScreen(),
        ),
        GoRoute(
          path: '/certificate/:courseName',
          builder: (context, state) {
            final courseName = state.pathParameters['courseName'] ?? 'Course';

            return CertificateScreen(
              courseName: courseName.replaceAll('-', ' '),
            );
          },
        ),

        // ---------------------------------------------------------------
        // Future learner workspaces
        // ---------------------------------------------------------------
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

        // ---------------------------------------------------------------
        // Instructor
        // ---------------------------------------------------------------
        GoRoute(
          path: '/instructor',
          builder: (context, state) => _rolePage(
            AppRole.instructor,
            '/instructor',
            'Dashboard',
            const InstructorDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/instructor/courses',
          builder: (context, state) => _rolePage(
            AppRole.instructor,
            '/instructor/courses',
            'My Courses',
            const MyCoursesScreen(),
          ),
        ),
        GoRoute(
          path: '/instructor/revenue',
          builder: (context, state) => _rolePage(
            AppRole.instructor,
            '/instructor/revenue',
            'Revenue',
            const InstructorRevenueScreen(),
          ),
        ),
        GoRoute(
          path: '/instructor/create-course',
          builder: (context, state) => _rolePage(
            AppRole.instructor,
            '/instructor/create-course',
            'Course Builder',
            const InstructorCreateCourseScreen(),
          ),
        ),
        GoRoute(
          path: '/instructor/course-builder/:id',
          builder: (context, state) {
            final courseId =
                int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

            return _rolePage(
              AppRole.instructor,
              state.location,
              'Course Builder',
              InstructorCourseBuilderScreen(courseId: courseId),
            );
          },
        ),
        GoRoute(
          path: '/instructor/go-live',
          builder: (context, state) => _rolePage(
            AppRole.instructor,
            '/instructor/go-live',
            'Go Live',
            const InstructorLiveScreen(),
          ),
        ),
        GoRoute(
          path: '/instructor/analytics',
          builder: (context, state) => _rolePage(
            AppRole.instructor,
            '/instructor/analytics',
            'Analytics',
            const InstructorAnalyticsScreen(),
          ),
        ),

        // ---------------------------------------------------------------
        // Corporate
        // ---------------------------------------------------------------
        GoRoute(
          path: '/corporate',
          builder: (context, state) => _rolePage(
            AppRole.corpAdmin,
            '/corporate',
            'Dashboard',
            const CorporateDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/corporate/employees',
          builder: (context, state) => _rolePage(
            AppRole.corpAdmin,
            '/corporate/employees',
            'Employees',
            const CorporateEmployeesScreen(),
          ),
        ),
        GoRoute(
          path: '/corporate/learning-paths',
          builder: (context, state) => _rolePage(
            AppRole.corpAdmin,
            '/corporate/learning-paths',
            'Learning Paths',
            const CorporateLearningPathsScreen(),
          ),
        ),
        GoRoute(
          path: '/corporate/reports',
          builder: (context, state) => _rolePage(
            AppRole.corpAdmin,
            '/corporate/reports',
            'Reports',
            const CorporateReportsScreen(),
          ),
        ),

        // ---------------------------------------------------------------
        // Employer
        // ---------------------------------------------------------------
        GoRoute(
          path: '/employer',
          builder: (context, state) => _rolePage(
            AppRole.employer,
            '/employer',
            'Dashboard',
            const EmployerDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/employer/jobs',
          builder: (context, state) => _rolePage(
            AppRole.employer,
            '/employer/jobs',
            'Jobs',
            const EmployerJobsScreen(),
          ),
        ),
        GoRoute(
          path: '/employer/applications',
          builder: (context, state) => _rolePage(
            AppRole.employer,
            '/employer/applications',
            'Applications',
            const EmployerApplicationsScreen(),
          ),
        ),
        GoRoute(
          path: '/employer/talent',
          builder: (context, state) => _rolePage(
            AppRole.employer,
            '/employer/talent',
            'Talent Search',
            const EmployerTalentScreen(),
          ),
        ),

        // ---------------------------------------------------------------
        // Admin
        // ---------------------------------------------------------------
        GoRoute(
          path: '/admin',
          builder: (context, state) => _rolePage(
            AppRole.admin,
            '/admin',
            'Dashboard',
            const AdminDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => _rolePage(
            AppRole.admin,
            '/admin/users',
            'Users',
            const AdminUsersScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/moderation',
          builder: (context, state) => _rolePage(
            AppRole.admin,
            '/admin/moderation',
            'Course Moderation',
            const AdminModerationScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/payments',
          builder: (context, state) => _rolePage(
            AppRole.admin,
            '/admin/payments',
            'Payments',
            const AdminPaymentsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (context, state) => _rolePage(
            AppRole.admin,
            '/admin/settings',
            'Settings',
            const AdminSettingsScreen(),
          ),
        ),
      ],
    );
  }
}

/// Logs router diagnostics only in debug mode.
void _routerLog(String message) {
  if (kDebugMode) {
    debugPrint('APP ROUTER: $message');
  }
}

/// Returns the role prefix required for a protected route.
///
/// Routes not listed here are public or intentionally accessible without
/// role-based redirection, including /otp and /interests.
String? _rolePrefixForPath(String path) {
  if (path == '/home' ||
      path == '/explore' ||
      path.startsWith('/explore/') ||
      path == '/my-learning' ||
      path.startsWith('/my-learning/') ||
      path == '/community' ||
      path.startsWith('/community/') ||
      path == '/profile' ||
      path.startsWith('/profile/') ||
      path.startsWith('/course/') ||
      path.startsWith('/checkout/') ||
      path.startsWith('/player/') ||
      path == '/quiz' ||
      path.startsWith('/quiz/') ||
      path == '/quiz-result' ||
      path == '/tutor' ||
      path.startsWith('/tutor/') ||
      path == '/ai-tutor' ||
      path.startsWith('/ai-tutor/') ||
      path.startsWith('/certificate/') ||
      path == '/skill-assessment' ||
      path.startsWith('/skill-assessment/') ||
      path == '/career-path' ||
      path.startsWith('/career-path/') ||
      path == '/live' ||
      path == '/jobs' ||
      path == '/learn' ||
      path.startsWith('/learn/') ||
      path == '/search' ||
      path == '/wallet' ||
      path == '/certificates' ||
      path == '/portfolio' ||
      path == '/settings' ||
      path == '/help' ||
      path == '/classic/home' ||
      path.startsWith('/classic/course/') ||
      path.startsWith('/classic/player/')) {
    return '/home';
  }

  for (final prefix in const [
    '/instructor',
    '/corporate',
    '/employer',
    '/admin',
  ]) {
    if (path == prefix || path.startsWith('$prefix/')) {
      return prefix;
    }
  }

  return null;
}

String _rolePrefixForRole(AppRole role) {
  switch (role) {
    case AppRole.learner:
      return '/home';
    case AppRole.instructor:
      return '/instructor';
    case AppRole.corpAdmin:
    case AppRole.corpManager:
      return '/corporate';
    case AppRole.employer:
      return '/employer';
    case AppRole.admin:
      return '/admin';
    case AppRole.guest:
      return '/home';
  }
}

Widget _rolePage(
  AppRole role,
  String route,
  String title,
  Widget child,
) {
  final actualRole =
      role == AppRole.corpAdmin && CurrentUser.role == AppRole.corpManager
          ? AppRole.corpManager
          : role;

  return RoleScaffold(
    role: actualRole,
    activeRoute: route,
    title: title,
    child: child,
  );
}
