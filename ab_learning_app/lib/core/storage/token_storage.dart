import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'default_backend_io.dart'
    if (dart.library.js_interop) 'default_backend_web.dart';
import 'key_value_backend.dart';
import 'secure_backend.dart';

/// Thin wrapper around the token storage so the rest of the app never touches
/// a storage package directly.
///
/// Mobile/desktop use the platform keystore. On the web each browser tab has
/// its own session (see `default_backend_web.dart`), which is what lets one
/// person use several tabs and roles at once.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage, KeyValueBackend? backend})
      : _backend = backend ??
            (storage != null ? SecureBackend(storage) : createDefaultBackend());

  final KeyValueBackend _backend;

  static const String _accessTokenKey = 'ab_learning.access_token';
  static const String _refreshTokenKey = 'ab_learning.refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _backend.write(_accessTokenKey, accessToken);
    await _backend.write(_refreshTokenKey, refreshToken);
  }

  Future<String?> readAccessToken() => _backend.read(_accessTokenKey);

  Future<String?> readRefreshToken() => _backend.read(_refreshTokenKey);

  Future<void> clear() async {
    await _backend.delete(_accessTokenKey);
    await _backend.delete(_refreshTokenKey);
  }
}
