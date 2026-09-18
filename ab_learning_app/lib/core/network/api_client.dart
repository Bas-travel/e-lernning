/// Abstract transport used by every feature repository.
///
/// Two implementations exist:
/// - [MockApiClient] — in-memory fixtures, zero network calls. This is what
///   the app uses today so the UI can be built and demoed before the Go
///   backend exists.
/// - [DioApiClient] — talks to the real `/api/v1/*` endpoints in
///   `05-openapi.yaml` once the backend is deployed.
///
/// Swapping between them is a one-line change in `lib/core/di/providers.dart`
/// — no feature code needs to change, because both implementations return
/// the same plain `Map<String, dynamic>` JSON shape described in the
/// OpenAPI spec.
abstract class ApiClient {
  /// POST /api/v1/auth/login
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  });

  /// GET /api/v1/home
  Future<Map<String, dynamic>> getHome();

  /// GET /api/v1/instructor/dashboard — INSTRUCTOR role only.
  Future<Map<String, dynamic>> getInstructorDashboard();

  /// GET /api/v1/corporate/dashboard — CORP_ADMIN / CORP_MANAGER only.
  Future<Map<String, dynamic>> getCorporateDashboard();

  /// GET /api/v1/employer/dashboard — EMPLOYER role only.
  Future<Map<String, dynamic>> getEmployerDashboard();

  /// GET /api/v1/employer/top-applicants — EMPLOYER role only.
  Future<List<dynamic>> getEmployerTopApplicants();

  /// GET /api/v1/admin/dashboard — ADMIN role only.
  Future<Map<String, dynamic>> getAdminDashboard();

  /// GET /api/v1/admin/courses/pending — ADMIN role only.
  Future<List<dynamic>> getAdminPendingCourses();

  /// POST /api/v1/admin/courses/{id}/approve — ADMIN role only.
  Future<void> approveCourse(int id);
}
