/// Mirrors the `Error` schema in `05-openapi.yaml`:
/// ```yaml
/// Error:
///   properties:
///     code: { type: string }
///     message: { type: string }
/// ```
/// Every repository should catch transport errors and rethrow this type so
/// the UI layer only ever has one error shape to handle.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  factory ApiException.network() => const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Could not reach the server. Check your connection.',
      );

  factory ApiException.unauthorized() => const ApiException(
        code: 'UNAUTHORIZED',
        message: 'Your session has expired. Please log in again.',
        statusCode: 401,
      );

  factory ApiException.invalidCredentials() => const ApiException(
        code: 'INVALID_CREDENTIALS',
        message: 'Email/phone or password is incorrect.',
        statusCode: 401,
      );

  /// Matches the Go backend's `platform.ErrForbidden` — a valid, logged-in
  /// user whose role isn't allowed on this endpoint. Distinct from
  /// [unauthorized] (no/expired session): this is "you ARE logged in, but
  /// not as the right role."
  factory ApiException.forbidden() => const ApiException(
        code: 'FORBIDDEN',
        message: "Your account doesn't have access to this.",
        statusCode: 403,
      );

  @override
  String toString() => 'ApiException($code): $message';
}
