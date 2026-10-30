
import '../../features/auth/data/account_repository.dart';
import '../../features/tutor/data/tutor_repository.dart';
import '../network/api_config.dart';
import '../network/rest_client.dart';
import '../network/token_store.dart';

/// Service locator for legacy screens and repositories.
class AppDependencies {
  static RestClient? _client;
  static AccountRepository? _auth;
  static TutorRepository? _tutor;

  /// Shared REST client and token store.
  static RestClient get apiClient =>
      _client ??= RestClient(tokenStore: SecureTokenStore());

  static AccountRepository get authRepository =>
      _auth ??= ApiConfig.useMockAuth
          ? MockAccountRepository()
          : ApiAccountRepository(apiClient);

  static set authRepository(AccountRepository value) {
    _auth = value;
  }

  static TutorRepository get tutorRepository =>
      _tutor ??= ApiConfig.useMockAuth
          ? MockTutorRepository()
          : ApiTutorRepository(apiClient);

  static set tutorRepository(TutorRepository value) {
    _tutor = value;
  }

  static void reset() {
    _client = null;
    _auth = null;
    _tutor = null;
  }
}
