import 'package:dio/dio.dart';

/// Error surfaced to the UI. [message] is safe to show to the user.
class RestException implements Exception {
  const RestException(this.message, {this.code, this.statusCode});

  final String message;

  /// Machine readable code from the `Error` schema (e.g. `COURSE_NOT_FOUND`).
  final String? code;

  /// HTTP status; `null` when the server could not be reached.
  final int? statusCode;

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;

  static const networkMessage =
      'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ กรุณาตรวจสอบอินเทอร์เน็ตแล้วลองใหม่';
  static const unauthorizedMessage = 'อีเมล เบอร์โทร หรือรหัสผ่านไม่ถูกต้อง';
  static const unknownMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';

  factory RestException.fromDio(DioException e) {
    final response = e.response;
    if (response == null) {
      return const RestException(networkMessage);
    }

    final status = response.statusCode;
    if (status == 401) {
      return RestException(
        unauthorizedMessage,
        code: _codeOf(response.data),
        statusCode: status,
      );
    }

    String? message;
    final data = response.data;
    if (data is Map) {
      // `Error` schema is {code, message}; the Go stub answers {error}.
      final raw = data['message'] ?? data['error'];
      if (raw is String && raw.trim().isNotEmpty) message = raw.trim();
    }
    message ??= (status != null && status >= 500)
        ? 'เซิร์ฟเวอร์ขัดข้อง ($status) กรุณาลองใหม่ภายหลัง'
        : 'คำขอไม่สำเร็จ (${status ?? '-'})';

    return RestException(message, code: _codeOf(data), statusCode: status);
  }

  static String? _codeOf(Object? data) {
    if (data is Map && data['code'] is String) return data['code'] as String;
    return null;
  }

  @override
  String toString() => 'RestException($statusCode, $code, $message)';
}
