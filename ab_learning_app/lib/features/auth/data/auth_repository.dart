import 'package:dio/dio.dart';

class AuthRepository {
  AuthRepository({Dio? client}) : _client = client ?? Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  final Dio _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/api/v1/auth/login',
      data: {
        'identifier': email,
        'password': password,
      },
    );
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Authentication failed',
      );
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final response = await _client.post(
      '/api/v1/auth/register',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    if (response.statusCode != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Registration failed',
      );
    }
    return Map<String, dynamic>.from(response.data as Map);
  }
}