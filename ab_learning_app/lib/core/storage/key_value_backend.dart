/// Where [TokenStorage] keeps its values. Swappable so the web build can use
/// per-tab storage while mobile and desktop keep the platform keystore.
abstract class KeyValueBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}
