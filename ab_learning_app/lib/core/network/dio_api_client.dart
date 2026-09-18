import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';
import '../storage/token_storage.dart';

/// Real implementation of [ApiClient], wired to the Go backend once it is
/// deployed. Endpoint paths match `05-openapi.yaml` exactly.
///
/// Not used yet — see `lib/core/di/providers.dart`, which currently injects
/// [MockApiClient] everywhere. Switch the provider to this class (and supply
/// [baseUrl]) when the backend from `06-project-structure.md` is live.
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
  Future<Map<String, dynamic>> getHome() async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get('/home');
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
