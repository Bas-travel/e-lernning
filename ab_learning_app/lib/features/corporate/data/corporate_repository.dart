import '../../../core/network/api_client.dart';
import '../models/corporate_dashboard.dart';

/// Wraps [ApiClient] calls for screen 36 (Corporate Dashboard).
class CorporateRepository {
  CorporateRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// GET /api/v1/corporate/dashboard
  Future<CorporateDashboard> getDashboard() async {
    final Map<String, dynamic> json = await _apiClient.getCorporateDashboard();
    return CorporateDashboard.fromJson(json);
  }
}
