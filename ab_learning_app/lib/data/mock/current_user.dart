import 'models.dart';
import '../../core/navigation/role_menus.dart';

/// Mock "logged in session" — replace with real state from
/// `POST /api/v1/auth/login` (see `AuthTokenResponse.user` in
/// `05-openapi.yaml`) once the backend is wired up. Until then, the Login
/// screen's role picker calls [loginAs] directly so every role's shell can
/// be demoed from one app without separate backend accounts.
class CurrentUser {
  CurrentUser._();

  static AppRole role = AppRole.learner;
  static String name = 'Learner';
  static String email = 'learner@ablearning.co';

  static void loginAs(AppRole newRole) {
    loginWith(
      role: newRole,
      name: newRole.label,
      email: '${newRole.name}@ablearning.co',
    );
  }

  static void loginWith({
    required AppRole role,
    required String name,
    required String email,
  }) {
    CurrentUser.role = role;
    CurrentUser.name = name;
    CurrentUser.email = email;
  }

  static void logout() {
    role = AppRole.learner;
    name = 'Learner';
    email = 'learner@ablearning.co';
  }

  /// Initial shell route for a role, used right after login.
  static String homeRouteFor(AppRole r) => homeRouteForRole(r);
  // static String homeRouteFor(AppRole r) {
  //   switch (r) {
  //     case AppRole.learner:
  //       return '/home';
  //     case AppRole.instructor:
  //       return '/instructor';
  //     case AppRole.corpAdmin:
  //     case AppRole.corpManager:
  //       return '/corporate';
  //     case AppRole.employer:
  //       return '/employer';
  //     case AppRole.admin:
  //       return '/admin';
  //   }
  // }
}
