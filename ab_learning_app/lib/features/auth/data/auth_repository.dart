import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_result.dart';

/// Wraps [ApiClient] calls for the Authentication domain (screens 01–07)
/// and persists tokens on success. Screens never call [ApiClient] directly
/// — only through a repository like this one — so token persistence and
/// error mapping live in exactly one place.
class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  /// POST /api/v1/auth/login (screen 03)
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _apiClient.login(
      identifier: identifier,
      password: password,
    );
    final AuthResult result = AuthResult.fromJson(json);
    await _tokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    return result;
  }

  Future<void> logout() => _tokenStorage.clear();

  Future<bool> hasSession() async {
    final String? token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
