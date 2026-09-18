import '../../../core/network/api_client.dart';
import '../models/admin_dashboard.dart';

/// Wraps [ApiClient] calls for screens 40–41 (Admin Dashboard, Course
/// Moderation).
class AdminRepository {
  AdminRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// GET /api/v1/admin/dashboard
  Future<AdminDashboard> getDashboard() async {
    final Map<String, dynamic> json = await _apiClient.getAdminDashboard();
    return AdminDashboard.fromJson(json);
  }

  /// GET /api/v1/admin/courses/pending
  Future<List<PendingCourse>> getPendingCourses() async {
    final List<dynamic> json = await _apiClient.getAdminPendingCourses();
    return json
        .map((dynamic e) => PendingCourse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/admin/courses/{id}/approve
  Future<void> approveCourse(int id) => _apiClient.approveCourse(id);
}
