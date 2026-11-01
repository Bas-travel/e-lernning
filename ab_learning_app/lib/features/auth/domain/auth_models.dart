/// User as described by the OpenAPI `User` schema (all fields tolerant).
class AuthUser {
  const AuthUser({
    this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.avatarUrl,
  });

  final int? id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? avatarUrl;

  AuthUser copyWith({String? firstName, String? lastName}) => AuthUser(
        id: id,
        email: email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        role: role,
        avatarUrl: avatarUrl,
      );

  String get displayName {
    final parts = [firstName, lastName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ');
    return parts.isEmpty ? email : parts;
  }

  String get initial {
    final source = displayName.trim();
    return source.isEmpty ? '?' : source.substring(0, 1).toUpperCase();
  }

  factory AuthUser.fromJson(Map<String, dynamic> json, {String? fallbackEmail}) {
    return AuthUser(
      id: (json['id'] as num?)?.toInt(),
      email: (json['email'] as String?) ?? fallbackEmail ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final AuthUser? user;
}
