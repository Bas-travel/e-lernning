import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/models.dart';
import '../../data/mock/current_user.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/corporate/presentation/corporate_dashboard_screen.dart';
import '../../features/corporate/presentation/corporate_workflows.dart';
import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/curriculum_screen.dart';
import '../../features/course/presentation/payment_screen.dart';
import '../../features/course/presentation/video_player_screen.dart';
import '../../features/employer/presentation/employer_dashboard_screen.dart';
import '../../features/employer/presentation/employer_workflows.dart';
import '../../features/instructor/presentation/instructor_dashboard_screen.dart';
import '../../features/instructor/presentation/instructor_revenue_screen.dart';
import '../../features/instructor/presentation/my_courses_screen.dart';
import '../../features/instructor/presentation/instructor_workflows.dart';
import '../../features/admin/presentation/admin_workflows.dart';
import '../../features/quiz/presentation/quiz_result_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import '../widgets/main_shell.dart';
import '../widgets/role_scaffold.dart';
import '../navigation/role_menus.dart';

final appRouterProvider = Provider<GoRouter>((ref) => AppRouter().router);

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen()),
        GoRoute(
            path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen()),

        // --- Learner (bottom-nav shell: Home / Explore / My Learning / AI Tutor)
        GoRoute(path: '/home', builder: (context, state) => const MainShell()),
        GoRoute(
            path: '/explore',
            builder: (context, state) => const MainShell(initialIndex: 1)),
        GoRoute(
            path: '/my-learning',
            builder: (context, state) => const MainShell(initialIndex: 2)),
        GoRoute(
            path: '/community',
            builder: (context, state) => const MainShell(initialIndex: 3)),
        GoRoute(
            path: '/profile',
            builder: (context, state) => const MainShell(initialIndex: 5)),

        GoRoute(
          path: '/course/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return CourseDetailScreen(courseId: id);
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
          path: '/player/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return VideoPlayerScreen(lessonId: id);
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
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            return QuizResultScreen(
              result: extra['result'] as QuizAttemptResult,
              questions: extra['questions'] as List<QuizQuestion>,
              lessonId: extra['lessonId'] as String,
            );
          },
        ),

        GoRoute(
          path: '/tutor',
          builder: (context, state) {
            final contextTitle = state.extra as String?;
            return MainShell(initialIndex: 4, tutorContext: contextTitle);
          },
        ),

        // --- Instructor (Phase 2: RBAC + Role Shell) ------------------------
        GoRoute(
            path: '/instructor',
            builder: (context, state) => _rolePage(AppRole.instructor, '/instructor', 'Dashboard', const InstructorDashboardScreen())),
        GoRoute(
            path: '/instructor/courses',
            builder: (context, state) => _rolePage(AppRole.instructor, '/instructor/courses', 'My Courses', const MyCoursesScreen())),
        GoRoute(
            path: '/instructor/revenue',
            builder: (context, state) => _rolePage(AppRole.instructor, '/instructor/revenue', 'Revenue', const InstructorRevenueScreen())),
        GoRoute(
          path: '/instructor/create-course',
          builder: (context, state) => _rolePage(AppRole.instructor, '/instructor/create-course', 'Course Builder', const InstructorCreateCourseScreen()),
        ),
        GoRoute(
          path: '/instructor/go-live',
          builder: (context, state) => _rolePage(AppRole.instructor, '/instructor/go-live', 'Go Live', const InstructorLiveScreen()),
        ),
        GoRoute(path: '/instructor/analytics', builder: (context, state) => _rolePage(AppRole.instructor, '/instructor/analytics', 'Analytics', const InstructorAnalyticsScreen())),

        // --- Corporate (Phase 2: RBAC + Role Shell) -------------------------
        GoRoute(
            path: '/corporate',
            builder: (context, state) => _rolePage(AppRole.corpAdmin, '/corporate', 'Dashboard', const CorporateDashboardScreen())),
        GoRoute(
          path: '/corporate/employees',
          builder: (context, state) => _rolePage(AppRole.corpAdmin, '/corporate/employees', 'Employees', const CorporateEmployeesScreen()),
        ),
        GoRoute(
          path: '/corporate/learning-paths',
          builder: (context, state) => _rolePage(AppRole.corpAdmin, '/corporate/learning-paths', 'Learning Paths', const CorporateLearningPathsScreen()),
        ),
        GoRoute(path: '/corporate/reports', builder: (context, state) => _rolePage(AppRole.corpAdmin, '/corporate/reports', 'Reports', const CorporateReportsScreen())),

        // --- Employer (Phase 2: RBAC + Role Shell) --------------------------
        GoRoute(
            path: '/employer',
            builder: (context, state) => _rolePage(AppRole.employer, '/employer', 'Dashboard', const EmployerDashboardScreen())),
        GoRoute(path: '/employer/jobs', builder: (context, state) => _rolePage(AppRole.employer, '/employer/jobs', 'Jobs', const EmployerJobsScreen())),
        GoRoute(path: '/employer/applications', builder: (context, state) => _rolePage(AppRole.employer, '/employer/applications', 'Applications', const EmployerApplicationsScreen())),
        GoRoute(path: '/employer/talent', builder: (context, state) => _rolePage(AppRole.employer, '/employer/talent', 'Talent Search', const EmployerTalentScreen())),

        // --- Admin (Phase 2: RBAC + Role Shell) -----------------------------
        GoRoute(
            path: '/admin',
            builder: (context, state) => _rolePage(AppRole.admin, '/admin', 'Dashboard', const AdminDashboardScreen())),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => _rolePage(AppRole.admin, '/admin/users', 'Users', const AdminUsersScreen()),
        ),
        GoRoute(
          path: '/admin/moderation',
          builder: (context, state) => _rolePage(AppRole.admin, '/admin/moderation', 'Course Moderation', const AdminModerationScreen()),
        ),
        GoRoute(
          path: '/admin/payments',
          builder: (context, state) => _rolePage(AppRole.admin, '/admin/payments', 'Payments', const AdminPaymentsScreen()),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (context, state) => _rolePage(AppRole.admin, '/admin/settings', 'Settings', const AdminSettingsScreen()),
        ),
      ],
    );
  }
}

Widget _rolePage(AppRole role, String route, String title, Widget child) {
  final actualRole = role == AppRole.corpAdmin &&
          CurrentUser.role == UserRole.corpManager
      ? AppRole.corpManager
      : role;
  return RoleScaffold(
      role: actualRole, activeRoute: route, title: title, child: child);
}
