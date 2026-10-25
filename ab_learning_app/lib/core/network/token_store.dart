import 'package:shared_preferences/shared_preferences.dart';

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
