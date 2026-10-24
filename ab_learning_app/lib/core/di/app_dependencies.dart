import '../../features/auth/data/auth_repository.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../network/token_store.dart';

/// Minimal service locator (the app does not use Riverpod providers yet).
/// Tests replace [authRepository] with a fake and call [reset] afterwards.
class AppDependencies {
  static AuthRepository? _auth;

  static AuthRepository get authRepository =>
      _auth ??= ApiConfig.useMockAuth
          ? MockAuthRepository()
          : ApiAuthRepository(ApiClient(tokenStore: PersistentTokenStore()));

  static set authRepository(AuthRepository value) => _auth = value;

  static void reset() => _auth = null;
}
