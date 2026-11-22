import 'package:ab_learning_app/core/storage/key_value_backend.dart';
import 'package:ab_learning_app/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _MapBackend implements KeyValueBackend {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  test('round trip and clear', () async {
    final storage = TokenStorage(backend: _MapBackend());
    await storage.saveTokens(accessToken: 'a1', refreshToken: 'r1');
    expect(await storage.readAccessToken(), 'a1');
    expect(await storage.readRefreshToken(), 'r1');

    await storage.clear();
    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
  });

  test('two sessions with separate backends do not overwrite each other',
      () async {
    // Models two browser tabs: each has its own per-tab backend.
    final tabA = TokenStorage(backend: _MapBackend());
    final tabB = TokenStorage(backend: _MapBackend());

    await tabA.saveTokens(accessToken: 'learner', refreshToken: 'rl');
    await tabB.saveTokens(accessToken: 'admin', refreshToken: 'ra');

    expect(await tabA.readAccessToken(), 'learner');
    expect(await tabB.readAccessToken(), 'admin');

    await tabB.clear();
    expect(await tabA.readAccessToken(), 'learner');
  });
}
