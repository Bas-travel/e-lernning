import 'package:dio/dio.dart';

import '../../../core/network/rest_client.dart';
import '../../../core/network/rest_exception.dart';
import '../domain/auth_models.dart';

export '../domain/auth_models.dart';

/// Auth operations used by the UI. Implementations: [ApiAccountRepository]
/// (Go backend, contract in 05-openapi.yaml) and [MockAccountRepository]
/// (in-memory demo).
abstract class AccountRepository {
  /// Last known signed-in user (cached after login / profile fetch).
  AuthUser? get currentUser;

  /// Whether a stored access token exists.
  Future<bool> hasSession();

  /// `POST /auth/login`. [identifier] is an email or phone number.
  /// [remember] decides whether the tokens are persisted.
  Future<AuthSession> login({
    required String identifier,
    required String password,
    bool remember = true,
  });

  /// `POST /auth/register`. Returns the created user (its id is needed for OTP).
  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String password,
  });

  /// `POST /auth/verify-otp`.
  Future<void> verifyOtp({required int userId, required String code});

  /// `POST /auth/forgot-password`.
  Future<void> forgotPassword({required String email});

  /// `POST /me/preferences`. The API takes a single `goal`, so the first
  /// selected goal is sent.
  Future<void> savePreferences({
    required List<String> interests,
    required String level,
    required List<String> goals,
  });

  /// `GET /me`. Returns `null` when the session is no longer valid (the
  /// stored tokens are cleared); when offline the cached user is returned.
  Future<AuthUser?> fetchProfile();

  Future<void> logout();
}

/// [AccountRepository] backed by the Go API.
class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._client);

  final RestClient _client;
  AuthUser? _user;

  Dio get _dio => _client.dio;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<bool> hasSession() async {
    final token = await _client.tokenStore.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw RestException.fromDio(e);
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    throw const RestException(RestException.unknownMessage);
  }

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
    bool remember = true,
  }) {
    final id = identifier.trim();
    return _guard(() async {
      final response = await _dio.post<Object?>(
        '/auth/login',
        data: {
          'identifier': id,
          // The Go stub still reads `email`; spec-compliant servers ignore it.
          if (id.contains('@')) 'email': id,
          'password': password,
        },
      );
      final json = _asMap(response.data);

      // Spec: {access_token, refresh_token, user}; stub: {token}.
      final access = json['access_token'] ?? json['token'];
      if (access is! String || access.isEmpty) {
        throw const RestException(RestException.unknownMessage);
      }
      final refresh = json['refresh_token'];
      final userJson = json['user'];
      final user = userJson is Map<String, dynamic>
          ? AuthUser.fromJson(userJson, fallbackEmail: id)
          : AuthUser(email: id);

      await _client.tokenStore.save(
        accessToken: access,
        refreshToken: refresh is String ? refresh : null,
        persist: remember,
      );
      _user = user;
      return AuthSession(
        accessToken: access,
        refreshToken: refresh is String ? refresh : null,
        user: user,
      );
    });
  }

  @override
  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String password,
  }) {
    final cleanPhone = phone?.trim() ?? '';
    return _guard(() async {
      final response = await _dio.post<Object?>(
        '/auth/register',
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'email': email.trim(),
          if (cleanPhone.isNotEmpty) 'phone': cleanPhone,
          'password': password,
        },
      );
      return AuthUser.fromJson(
        _asMap(response.data),
        fallbackEmail: email.trim(),
      );
    });
  }

  /// The Go API has no OTP or preferences endpoints yet (`/auth/register`
  /// already activates the account). "Route not found" is treated as a no-op
  /// so onboarding is not a dead end; every other failure still surfaces.
  Future<void> _skipIfUnimplemented(Future<void> Function() request) async {
    try {
      await request();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 405 || status == 501) return;
      throw RestException.fromDio(e);
    }
  }

  @override
  Future<void> verifyOtp({required int userId, required String code}) {
    return _skipIfUnimplemented(() async {
      await _dio.post<Object?>(
        '/auth/verify-otp',
        data: {'user_id': userId, 'code': code},
      );
    });
  }

  @override
  Future<void> forgotPassword({required String email}) {
    return _guard(() async {
      await _dio.post<Object?>(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
    });
  }

  @override
  Future<void> savePreferences({
    required List<String> interests,
    required String level,
    required List<String> goals,
  }) {
    return _skipIfUnimplemented(() async {
      await _dio.post<Object?>(
        '/me/preferences',
        data: {
          'interests': interests,
          'level': level.toLowerCase(),
          if (goals.isNotEmpty) 'goal': goals.first,
        },
      );
    });
  }

  @override
  Future<AuthUser?> fetchProfile() async {
    try {
      final response = await _dio.get<Object?>('/me');
      final user = AuthUser.fromJson(
        _asMap(response.data),
        fallbackEmail: _user?.email,
      );
      _user = user;
      return user;
    } on DioException catch (e) {
      final error = RestException.fromDio(e);
      if (error.isUnauthorized) {
        await logout();
        return null;
      }
      // Offline or server trouble: keep showing what we already know.
      return _user;
    }
  }

  @override
  Future<void> logout() async {
    await _client.tokenStore.clear();
    _user = null;
  }
}

/// In-memory [AccountRepository] for demos (`--dart-define=USE_MOCK_AUTH=true`)
/// and tests. Accepts any credentials.
class MockAccountRepository implements AccountRepository {
  MockAccountRepository({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;
  AuthUser? _user;
  bool _signedIn = false;

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<bool> hasSession() async => _signedIn;

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
    bool remember = true,
  }) async {
    await _wait();
    _signedIn = true;
    _user = AuthUser(email: identifier.trim());
    return AuthSession(accessToken: 'mock-access-token', user: _user);
  }

  @override
  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String password,
  }) async {
    await _wait();
    return AuthUser(
      id: 1,
      email: email.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
    );
  }

  @override
  Future<void> verifyOtp({required int userId, required String code}) => _wait();

  @override
  Future<void> forgotPassword({required String email}) => _wait();

  @override
  Future<void> savePreferences({
    required List<String> interests,
    required String level,
    required List<String> goals,
  }) =>
      _wait();

  @override
  Future<AuthUser?> fetchProfile() async => _signedIn ? _user : null;

  @override
  Future<void> logout() async {
    _signedIn = false;
    _user = null;
  }
}
