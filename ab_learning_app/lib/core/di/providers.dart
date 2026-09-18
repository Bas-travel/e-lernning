import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/mock_api_client.dart';
import '../storage/token_storage.dart';

/// ---------------------------------------------------------------------
/// SINGLE SWITCH POINT: mock vs real backend
/// ---------------------------------------------------------------------
/// Everything in the app depends on [apiClientProvider], never on
/// [MockApiClient] or [DioApiClient] directly. To connect to the real Go
/// API once it's deployed, change this to:
///
/// ```dart
/// final apiClientProvider = Provider<ApiClient>((ref) {
///   return DioApiClient(
///     baseUrl: 'https://api.ablearning.co/api/v1',
///     tokenStorage: ref.watch(tokenStorageProvider),
///   );
/// });
/// ```
///
/// No feature/repository/screen code needs to change.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return MockApiClient();
});

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((ref) {
  return TokenStorage();
});
