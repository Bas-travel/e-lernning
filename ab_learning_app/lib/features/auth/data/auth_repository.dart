import '../../../core/network/api_client.dart';
import '../../../core/network/mock_api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthResult {
  const AuthResult({required this.user});

  final User user;
}

class AuthRepository {
  AuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? MockApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AuthResult> login({required String identifier, required String password}) async {
    final response = await _apiClient.login(identifier: identifier, password: password);
    final userJson = response['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Login response does not contain a user.');
    }
    await _tokenStorage.saveTokens(
      accessToken: response['access_token'] as String? ?? '',
      refreshToken: response['refresh_token'] as String? ?? '',
    );
    return AuthResult(user: User.fromJson(userJson));
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    await _apiClient.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

  Future<void> logout() => _tokenStorage.clear();
}
