import '../../../core/network/api_client.dart';
import '../models/instructor_dashboard.dart';

/// Wraps [ApiClient] calls for screen 31 (Instructor Dashboard).
class InstructorRepository {
  InstructorRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// GET /api/v1/instructor/dashboard
  Future<InstructorDashboard> getDashboard() async {
    final Map<String, dynamic> json = await _apiClient.getInstructorDashboard();
    return InstructorDashboard.fromJson(json);
  }
}
