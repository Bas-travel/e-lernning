import '../../../core/network/api_client.dart';
import '../models/employer_dashboard.dart';

/// Wraps [ApiClient] calls for screen 39 (Employer Dashboard).
class EmployerRepository {
  EmployerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// GET /api/v1/employer/dashboard
  Future<EmployerDashboard> getDashboard() async {
    final Map<String, dynamic> json = await _apiClient.getEmployerDashboard();
    return EmployerDashboard.fromJson(json);
  }

  /// GET /api/v1/employer/top-applicants
  Future<List<TopApplicant>> getTopApplicants() async {
    final List<dynamic> json = await _apiClient.getEmployerTopApplicants();
    return json
        .map((dynamic e) => TopApplicant.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
