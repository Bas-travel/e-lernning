/// Mirrors the Go `admin.Dashboard` DTO exactly (screen 40's KPIs).
class AdminDashboard {
  const AdminDashboard({
    required this.totalUsers,
    required this.totalInstructors,
    required this.totalCourses,
    required this.totalRevenue,
    required this.pendingModeration,
  });

  final int totalUsers;
  final int totalInstructors;
  final int totalCourses;
  final double totalRevenue;
  final int pendingModeration;

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalUsers: json['total_users'] as int,
      totalInstructors: json['total_instructors'] as int,
      totalCourses: json['total_courses'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      pendingModeration: json['pending_moderation'] as int,
    );
  }
}

/// Mirrors the Go `admin.PendingCourse` DTO — screen 41's moderation queue.
class PendingCourse {
  const PendingCourse({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.category,
    required this.submittedAt,
  });

  final int id;
  final String title;
  final String instructorName;
  final String category;
  final String submittedAt;

  factory PendingCourse.fromJson(Map<String, dynamic> json) {
    return PendingCourse(
      id: json['id'] as int,
      title: json['title'] as String,
      instructorName: json['instructor_name'] as String,
      category: json['category'] as String,
      submittedAt: json['submitted_at'] as String? ?? '',
    );
  }
}
