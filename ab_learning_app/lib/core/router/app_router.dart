import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/models.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/corporate/presentation/corporate_dashboard_screen.dart';
import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/curriculum_screen.dart';
import '../../features/course/presentation/video_player_screen.dart';
import '../../features/employer/presentation/employer_dashboard_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/instructor/presentation/instructor_dashboard_screen.dart';
import '../../features/instructor/presentation/instructor_revenue_screen.dart';
import '../../features/instructor/presentation/my_courses_screen.dart';
import '../../features/my_learning/presentation/my_learning_screen.dart';
import '../../features/quiz/presentation/quiz_result_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import '../widgets/coming_soon_screen.dart';
import '../widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) => AppRouter().router);

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

        // --- Learner (bottom-nav shell: Home / Explore / My Learning / AI Tutor)
        GoRoute(path: '/home', builder: (context, state) => const MainShell()),
        GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
        GoRoute(path: '/my-learning', builder: (context, state) => const MyLearningScreen()),

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
            return AiTutorScreen(contextTitle: contextTitle ?? 'your learning journey');
          },
        ),

        // --- Instructor (Phase 2: RBAC + Role Shell) ------------------------
        GoRoute(path: '/instructor', builder: (context, state) => const InstructorDashboardScreen()),
        GoRoute(path: '/instructor/courses', builder: (context, state) => const MyCoursesScreen()),
        GoRoute(path: '/instructor/revenue', builder: (context, state) => const InstructorRevenueScreen()),
        GoRoute(
          path: '/instructor/create-course',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Create Course',
            description:
                'The 4-step course wizard and full Course Builder (with real '
                'video upload) are being built in Phase 3.',
            icon: Icons.video_call_outlined,
          ),
        ),
        GoRoute(
          path: '/instructor/go-live',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Go Live',
            description: 'Live session hosting (WebRTC) is planned for a later phase.',
            phaseLabel: 'a later phase',
            icon: Icons.podcasts_outlined,
          ),
        ),

        // --- Corporate (Phase 2: RBAC + Role Shell) -------------------------
        GoRoute(path: '/corporate', builder: (context, state) => const CorporateDashboardScreen()),
        GoRoute(
          path: '/corporate/employees',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Employee Management',
            description:
                'Search, filters, bulk actions and CSV import for managing employees '
                'are being built in Phase 3, wired to /api/v1/corporate/employees.',
          ),
        ),
        GoRoute(
          path: '/corporate/learning-paths',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Learning Paths',
            description:
                'Creating and assigning learning paths to employees is being built '
                'in Phase 3, wired to /api/v1/corporate/learning-paths.',
          ),
        ),

        // --- Employer (Phase 2: RBAC + Role Shell) --------------------------
        GoRoute(path: '/employer', builder: (context, state) => const EmployerDashboardScreen()),

        // --- Admin (Phase 2: RBAC + Role Shell) -----------------------------
        GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const ComingSoonScreen(
            title: 'User Management',
            description:
                'The full user table, role/status editing and suspend action are '
                'being built in Phase 3, wired to /api/v1/admin/users.',
          ),
        ),
        GoRoute(
          path: '/admin/moderation',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Course Moderation',
            description:
                'Reviewing pending courses with approve/reject actions is being '
                'built in Phase 3, wired to /api/v1/admin/courses/pending.',
          ),
        ),
        GoRoute(
          path: '/admin/payments',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Payment Management',
            description:
                'Transaction history, refunds and exports are being built in '
                'Phase 3, wired to /api/v1/admin/payments — and to a real payment '
                'gateway (e.g. Omise) in Phase 4.',
          ),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Platform Settings',
            description: 'Platform-wide configuration is planned for a later phase.',
            phaseLabel: 'a later phase',
            icon: Icons.settings_outlined,
          ),
        ),
      ],
    );
  }
}
