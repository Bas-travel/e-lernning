import 'package:shared_preferences/shared_preferences.dart';

import '../storage/token_storage.dart';

/// Holds the JWT pair. [persist] = false keeps tokens in memory only
/// ("Remember me" unchecked).
abstract class TokenStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> save({
    required String accessToken,
    String? refreshToken,
    bool persist = true,
  });
  Future<void> clear();
}

class MemoryTokenStore implements TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> save({
    required String accessToken,
    String? refreshToken,
    bool persist = true,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

/// Persists tokens with shared_preferences.
///
/// NOTE: shared_preferences is not encrypted storage. Move to
/// flutter_secure_storage before shipping to production.
class PersistentTokenStore implements TokenStore {
  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  String? _memoryAccess;
  String? _memoryRefresh;

  @override
  Future<String?> readAccessToken() async {
    if (_memoryAccess != null) return _memoryAccess;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  @override
  Future<String?> readRefreshToken() async {
    if (_memoryRefresh != null) return _memoryRefresh;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  @override
  Future<void> save({
    required String accessToken,
    String? refreshToken,
    bool persist = true,
  }) async {
    _memoryAccess = accessToken;
    _memoryRefresh = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    if (persist) {
      await prefs.setString(_accessKey, accessToken);
      if (refreshToken != null) {
        await prefs.setString(_refreshKey, refreshToken);
      } else {
        await prefs.remove(_refreshKey);
      }
    } else {
      await prefs.remove(_accessKey);
      await prefs.remove(_refreshKey);
    }
  }

  @override
  Future<void> clear() async {
    _memoryAccess = null;
    _memoryRefresh = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }
}

/// Stores the JWT pair in the platform keystore through [TokenStorage]
/// (flutter_secure_storage). This is the same storage the Riverpod
/// `DioApiClient` reads, so a login made through [RestClient] also
/// authenticates the role dashboards.
///
/// [persist] is ignored: both clients read from the shared keystore, so the
/// tokens are always written there. "Remember me" therefore only affects UI
/// state until a session-only mode is added to [TokenStorage].
class SecureTokenStore implements TokenStore {
  SecureTokenStore({TokenStorage? storage})
      : _storage = storage ?? TokenStorage();

  final TokenStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.readAccessToken();

  @override
  Future<String?> readRefreshToken() => _storage.readRefreshToken();

  @override
  Future<void> save({
    required String accessToken,
    String? refreshToken,
    bool persist = true,
  }) =>
      _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );

  @override
  Future<void> clear() => _storage.clear();
}
