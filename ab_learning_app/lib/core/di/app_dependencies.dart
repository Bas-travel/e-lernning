import '../../features/auth/data/auth_repository.dart';
import '../../features/tutor/data/tutor_repository.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../network/token_store.dart';

/// Minimal service locator (the app does not use Riverpod providers yet).
/// Tests replace repositories with fakes and call [reset] afterwards.
class AppDependencies {
  static ApiClient? _client;
  static AuthRepository? _auth;
  static TutorRepository? _tutor;

  /// One client (and token store) shared by every API repository.
  static ApiClient get apiClient =>
      _client ??= ApiClient(tokenStore: PersistentTokenStore());

  static AuthRepository get authRepository =>
      _auth ??= ApiConfig.useMockAuth
          ? MockAuthRepository()
          : ApiAuthRepository(apiClient);

  static set authRepository(AuthRepository value) => _auth = value;

  static TutorRepository get tutorRepository =>
      _tutor ??= ApiConfig.useMockAuth
          ? MockTutorRepository()
          : ApiTutorRepository(apiClient);

  static set tutorRepository(TutorRepository value) => _tutor = value;

  static void reset() {
    _client = null;
    _auth = null;
    _tutor = null;
  }
}
