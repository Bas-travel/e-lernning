/// Abstract transport used by every feature repository.
///
/// Two implementations exist:
/// - [DioApiClient] — talks to the real `/api/v1/*` endpoints and is the
///   default for normal app builds.
/// - [MockApiClient] — in-memory fixtures for isolated demos and tests.
///
/// Select the mock client with `--dart-define=USE_MOCK_API=true`; no feature
/// code needs to change because both implementations return
/// the same plain `Map<String, dynamic>` JSON shape described in the
/// OpenAPI spec.
abstract class ApiClient {
  /// POST /api/v1/auth/login
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  });

  /// POST /api/v1/auth/register
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
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

  /// POST /api/v1/admin/courses/{id}/reject — ADMIN role only.
  Future<void> rejectCourse(int id, {required String reason});

  Future<Map<String, dynamic>> getInstructorRevenue();
  Future<List<dynamic>> getInstructorCourses({String? status});
  Future<Map<String, dynamic>> createInstructorCourse(
      Map<String, dynamic> body);
  Future<Map<String, dynamic>> getInstructorCourse(int id);
  Future<Map<String, dynamic>> createInstructorSection(
      Map<String, dynamic> body);
  Future<Map<String, dynamic>> createInstructorLesson(
      Map<String, dynamic> body);
  Future<Map<String, dynamic>> uploadInstructorVideo(
      {required List<int> bytes, required String filename});
  Future<Map<String, dynamic>> submitInstructorCourse(int id);

  Future<List<dynamic>> getCategories();
  Future<List<dynamic>> getCourses({String? query, int page = 1});

  Future<List<dynamic>> getCorporateEmployees(
      {String? query, String? department, String? status});
  Future<Map<String, dynamic>> addCorporateEmployee(Map<String, dynamic> body);
  Future<void> updateCorporateEmployee(int id, Map<String, dynamic> body);
  Future<List<dynamic>> getCorporateLearningPaths();
  Future<Map<String, dynamic>> createCorporateLearningPath(
      Map<String, dynamic> body);

  Future<List<dynamic>> getAdminUsers({String? query});
  Future<Map<String, dynamic>> updateAdminUser(
      int id, Map<String, dynamic> body);
  Future<Map<String, dynamic>> suspendAdminUser(int id, {String reason = ''});
  Future<List<dynamic>> getAdminPayments({String? status});
  Future<Map<String, dynamic>> refundAdminPayment(int id, {String reason = ''});

  Future<List<dynamic>> getEmployerJobs();
  Future<Map<String, dynamic>> createEmployerJob(Map<String, dynamic> body);
  Future<List<dynamic>> getEmployerApplications();
  Future<void> updateEmployerApplication(int id, {required String status});
}
