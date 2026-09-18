/// Mirrors the `User` schema in `05-openapi.yaml`.
class User {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });

  final int id;
  final String email;
  final String role; // GUEST, LEARNER, INSTRUCTOR, CORP_ADMIN, CORP_MANAGER, EMPLOYER, ADMIN
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';
  String get initial => firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'avatar_url': avatarUrl,
      };
}
