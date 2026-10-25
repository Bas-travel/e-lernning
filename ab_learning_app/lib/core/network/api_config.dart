/// Build-time API configuration.
///
/// Override with `--dart-define`, e.g.
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1`
/// (10.0.2.2 is the host machine when running on an Android emulator).
class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  /// `--dart-define=USE_MOCK_AUTH=true` runs the UI against an in-memory fake
  /// repository, handy for demos without the Go backend.
  static const useMockAuth = bool.fromEnvironment('USE_MOCK_AUTH');
}
