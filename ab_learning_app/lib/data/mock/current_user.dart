import 'models.dart';

/// Mock "logged in session" — replace with real state from
/// `POST /api/v1/auth/login` (see `AuthTokenResponse.user` in
/// `05-openapi.yaml`) once the backend is wired up. Until then, the Login
/// screen's role picker calls [loginAs] directly so every role's shell can
/// be demoed from one app without separate backend accounts.
class CurrentUser {
  CurrentUser._();

  static UserRole role = UserRole.learner;
  static String name = 'Learner';
  static String email = 'learner@ablearning.co';

  static void loginAs(UserRole newRole) {
    role = newRole;
    name = role.label;
    email = '${role.name}@ablearning.co';
  }

  static void logout() {
    role = UserRole.learner;
    name = 'Learner';
    email = 'learner@ablearning.co';
  }

  /// Initial shell route for a role, used right after login.
  static String homeRouteFor(UserRole r) {
    switch (r) {
      case UserRole.learner:
        return '/home';
      case UserRole.instructor:
        return '/instructor';
      case UserRole.corpAdmin:
      case UserRole.corpManager:
        return '/corporate';
      case UserRole.employer:
        return '/employer';
      case UserRole.admin:
        return '/admin';
    }
  }
}
