import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/mock_api_client.dart';
import '../network/dio_api_client.dart';
import '../storage/token_storage.dart';

/// ---------------------------------------------------------------------
/// SINGLE SWITCH POINT: mock vs real backend
/// ---------------------------------------------------------------------
/// The real API is the default. Override API_BASE_URL for deployment/device
/// networking, or opt into the local mock explicitly with USE_MOCK_API=true.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  const useMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);
  if (useMockApi) return MockApiClient();
  return DioApiClient(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    ),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final instructorDashboardProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(apiClientProvider).getInstructorDashboard(),
);
final corporateDashboardProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(apiClientProvider).getCorporateDashboard(),
);
final adminDashboardProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(apiClientProvider).getAdminDashboard(),
);
