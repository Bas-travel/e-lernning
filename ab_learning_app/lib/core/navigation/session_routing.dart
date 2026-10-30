import '../../data/mock/current_user.dart';
import '../../features/auth/domain/auth_models.dart';
import 'role_menus.dart';

/// Mirrors a signed-in [user] into [CurrentUser] (used by the role guard in
/// `app_router.dart` and the role shells) and returns the route that role
/// lands on. A missing or unknown role is treated as a learner so older
/// servers that omit `role` keep working.
String applySession(AuthUser? user) {
  if (user == null) {
    CurrentUser.logout();
    return homeRouteForRole(AppRole.learner);
  }
  final parsed = roleFromString((user.role ?? 'LEARNER').toUpperCase());
  final role = parsed == AppRole.guest ? AppRole.learner : parsed;
  CurrentUser.loginWith(
    role: role,
    name: user.displayName,
    email: user.email,
  );
  return homeRouteForRole(role);
}
