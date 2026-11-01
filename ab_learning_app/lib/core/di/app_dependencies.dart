import '../../features/auth/data/account_repository.dart';
import '../../features/tutor/data/tutor_repository.dart';
import '../network/rest_client.dart';
import '../network/api_config.dart';
import '../network/token_store.dart';

/// Minimal service locator (the app does not use Riverpod providers yet).
/// Tests replace repositories with fakes and call [reset] afterwards.
class AppDependencies {
  static RestClient? _client;
  static AccountRepository? _auth;
  static TutorRepository? _tutor;

  /// One client (and token store) shared by every API repository.
  static RestClient get apiClient =>
      _client ??= RestClient(tokenStore: SecureTokenStore());

  static AccountRepository get authRepository =>
      _auth ??= ApiConfig.useMockAuth
          ? MockAccountRepository()
          : ApiAccountRepository(apiClient);

  static set authRepository(AccountRepository value) => _auth = value;

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
