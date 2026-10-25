import 'package:dio/dio.dart';

import 'api_config.dart';
import 'token_store.dart';

/// Thin wrapper around [Dio]: base URL, timeouts, JSON headers and a `Bearer`
/// interceptor fed by [tokenStore]. Pass [dio] to inject a configured instance
/// (tests use this to plug in a fake adapter).
class ApiClient {
  ApiClient({required this.tokenStore, Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                contentType: Headers.jsonContentType,
                headers: const {'Accept': 'application/json'},
              ),
            ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final TokenStore tokenStore;
  final Dio dio;
}
