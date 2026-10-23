import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';
import '../storage/token_storage.dart';

/// Real implementation of [ApiClient] for the Go backend. Endpoint paths
/// match `05-openapi.yaml` and the corresponding backend handlers.
///
/// Auth is a request interceptor that reads [TokenStorage] fresh on every
/// call — NOT a token baked into [BaseOptions] at construction time. This
/// matters: this client is built once (in `providers.dart`) before login
/// ever happens, so a static header would always be empty. Reading storage
/// per-request means the very next call after `login()` succeeds is
/// already authenticated, with no need to rebuild the client.
class DioApiClient implements ApiClient {
  DioApiClient({required String baseUrl, required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.post(
        '/auth/login',
        data: <String, dynamic>{
          'identifier': identifier,
          'password': password,
        },
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.post(
        '/auth/register',
        data: <String, dynamic>{
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        },
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getHome() async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.get('/home');
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getInstructorDashboard() async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get('/instructor/dashboard');
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getCorporateDashboard() async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get('/corporate/dashboard');
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getEmployerDashboard() async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get('/employer/dashboard');
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getEmployerTopApplicants() async {
    try {
      final Response<List<dynamic>> response =
          await _dio.get('/employer/top-applicants');
      return response.data ?? <dynamic>[];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get('/admin/dashboard');
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getAdminPendingCourses() async {
    try {
      final Response<List<dynamic>> response =
          await _dio.get('/admin/courses/pending');
      return response.data ?? <dynamic>[];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> approveCourse(int id) async {
    try {
      await _dio.post('/admin/courses/$id/approve');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> rejectCourse(int id, {required String reason}) async {
    try {
      await _dio.post('/admin/courses/$id/reject',
          data: <String, dynamic>{'reason': reason});
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getInstructorRevenue() =>
      _getMap('/instructor/revenue');

  @override
  Future<List<dynamic>> getInstructorCourses({String? status}) =>
      _getList('/instructor/courses',
          query: {if (status != null) 'status': status});

  @override
  Future<Map<String, dynamic>> createInstructorCourse(
          Map<String, dynamic> body) =>
      _postMap('/instructor/courses', body);

  @override
  Future<Map<String, dynamic>> getInstructorCourse(int id) =>
      _getMap('/instructor/courses/$id');

  @override
  Future<Map<String, dynamic>> createInstructorSection(
          Map<String, dynamic> body) =>
      _postMap('/course-sections', body);

  @override
  Future<Map<String, dynamic>> createInstructorLesson(
          Map<String, dynamic> body) =>
      _postMap('/lessons', body);

  @override
  Future<Map<String, dynamic>> uploadInstructorVideo(
      {required List<int> bytes, required String filename}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/instructor/uploads/video',
        data: FormData.fromMap(
            {'file': MultipartFile.fromBytes(bytes, filename: filename)}),
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> submitInstructorCourse(int id) =>
      _postMap('/instructor/courses/$id/submit', const {});

  @override
  Future<List<dynamic>> getCategories() => _getList('/categories');

  @override
  Future<List<dynamic>> getCourses({String? query, int page = 1}) =>
      _getList('/courses',
          query: {if (query != null) 'q': query, 'page': page});

  @override
  Future<List<dynamic>> getCorporateEmployees(
          {String? query, String? department, String? status}) =>
      _getList('/corporate/employees', query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (department != null && department.isNotEmpty)
          'department': department,
        if (status != null && status.isNotEmpty) 'status': status,
      });

  @override
  Future<Map<String, dynamic>> addCorporateEmployee(
          Map<String, dynamic> body) =>
      _postMap('/corporate/employees', body);

  @override
  Future<void> updateCorporateEmployee(
      int id, Map<String, dynamic> body) async {
    try {
      await _dio.put('/corporate/employees/$id', data: body);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getCorporateLearningPaths() =>
      _getList('/corporate/learning-paths');

  @override
  Future<Map<String, dynamic>> createCorporateLearningPath(
          Map<String, dynamic> body) =>
      _postMap('/corporate/learning-paths', body);

  @override
  Future<List<dynamic>> getAdminUsers({String? query}) =>
      _getList('/admin/users',
          query: {if (query != null && query.isNotEmpty) 'q': query});

  @override
  Future<Map<String, dynamic>> updateAdminUser(
      int id, Map<String, dynamic> body) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.put('/admin/users/$id', data: body);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> suspendAdminUser(int id, {String reason = ''}) =>
      _postMap('/admin/users/$id/suspend', {'reason': reason});

  @override
  Future<List<dynamic>> getAdminPayments({String? status}) =>
      _getList('/admin/payments',
          query: {if (status != null) 'status': status});

  @override
  Future<Map<String, dynamic>> refundAdminPayment(int id,
          {String reason = ''}) =>
      _postMap('/admin/payments/$id/refund', {'reason': reason});

  @override
  Future<List<dynamic>> getEmployerJobs() => _getList('/employer/jobs');

  @override
  Future<Map<String, dynamic>> createEmployerJob(Map<String, dynamic> body) =>
      _postMap('/employer/jobs', body);

  @override
  Future<List<dynamic>> getEmployerApplications() =>
      _getList('/employer/applications');

  @override
  Future<void> updateEmployerApplication(int id,
      {required String status}) async {
    try {
      await _dio.put('/employer/applications/$id', data: {'status': status});
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.get(path);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<dynamic>> _getList(String path,
      {Map<String, dynamic>? query}) async {
    try {
      final Response<List<dynamic>> response =
          await _dio.get(path, queryParameters: query);
      return response.data ?? <dynamic>[];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> _postMap(
      String path, Map<String, dynamic> body) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.post(path, data: body);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Prefers the backend's own `{code, message}` body (see Go's
  /// `platform.AppError`) since it's always more specific than guessing
  /// from the HTTP status alone — e.g. a 401 on `/auth/login` means wrong
  /// password, but a 401 on `/home` means an expired session, and the
  /// backend already tells us which via `code`.
  ApiException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return ApiException.network();
    }
    final dynamic data = e.response?.data;
    if (data is Map<String, dynamic> && data['code'] is String) {
      return ApiException(
        code: data['code'] as String,
        message: (data['message'] as String?) ?? 'Something went wrong.',
        statusCode: e.response?.statusCode,
      );
    }
    // No structured body to read (network hiccup, proxy error page, etc.)
    // — fall back to a reasonable guess from the status code alone.
    switch (e.response?.statusCode) {
      case 401:
        return ApiException.unauthorized();
      case 403:
        return ApiException.forbidden();
      default:
        return ApiException(
          code: 'UNKNOWN_ERROR',
          message: e.message ?? 'Something went wrong.',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
