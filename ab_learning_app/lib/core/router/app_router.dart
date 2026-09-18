import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/corporate/presentation/corporate_dashboard_screen.dart';
import '../../features/employer/presentation/employer_dashboard_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/instructor/presentation/instructor_dashboard_screen.dart';
import '../navigation/role_menus.dart';

/// One route per screen ID from `01-screens-spec.md`, now covering every
/// role's landing screen (03 Login, 08 Home, 31 Instructor, 36 Corporate,
/// 39 Employer, 40 Admin) — add the rest as each feature is built,
/// following the same `features/<name>/presentation/` pattern.
///
/// ROLE GUARDING: `redirect` runs on every navigation attempt (including
/// deep links and browser back/forward on web) and enforces two rules:
///   1. No session -> always bounced to /login.
///   2. A session that doesn't own the route it's trying to reach -> bounced
///      to ITS OWN home route, not /login. A Learner typing /admin into the
///      address bar on web should land on their own Home, not see a blank
///      screen or an error — this mirrors the Go backend's 403 behavior
///      (valid session, wrong role) rather than a 401 (no session).
///
/// NOTE: this reads `authControllerProvider` once per navigation attempt,
/// which is enough here because every screen that changes auth state
/// (login, logout) explicitly calls `context.go(...)` right after. For a
/// fully reactive redirect (e.g. auto-bouncing the instant a token expires
/// mid-session), wire a `GoRouterRefreshStream` off
/// `authControllerProvider.stream` and pass it as `refreshListenable` below.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
      final String location = state.matchedLocation;
      final bool isLoggingIn = location == '/login';

      if (!auth.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // Authenticated. Never let a logged-in user sit on /login.
      final String home = homeRouteForRole(auth.role);
      if (isLoggingIn) return home;

      // Role ownership check: each top-level route belongs to exactly one
      // role's home. A session whose role doesn't own the section it's
      // requesting gets redirected to its own home instead.
      const Map<String, AppRole> routeOwner = <String, AppRole>{
        '/home': AppRole.learner,
        '/instructor': AppRole.instructor,
        '/employer': AppRole.employer,
        '/admin': AppRole.admin,
        // '/corporate' intentionally omitted: both CORP_ADMIN and
        // CORP_MANAGER own it, checked separately below.
      };
      if (location == '/corporate') {
        final bool corpOwnsIt =
            auth.role == AppRole.corpAdmin || auth.role == AppRole.corpManager;
        if (!corpOwnsIt) return home;
      } else {
        final AppRole? owner = routeOwner[location];
        if (owner != null && owner != auth.role) return home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/instructor',
        name: 'instructor',
        builder: (context, state) => const InstructorDashboardScreen(),
      ),
      GoRoute(
        path: '/corporate',
        name: 'corporate',
        builder: (context, state) => const CorporateDashboardScreen(),
      ),
      GoRoute(
        path: '/employer',
        name: 'employer',
        builder: (context, state) => const EmployerDashboardScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // Next up, following 01-screens-spec.md build order:
      // GoRoute(path: '/explore', ...)          // screen 09
      // GoRoute(path: '/course/:id', ...)       // screen 11
      // GoRoute(path: '/ai-tutor', ...)         // screen 21
    ],
  );
});
