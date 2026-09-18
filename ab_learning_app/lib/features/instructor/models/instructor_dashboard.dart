/// Mirrors the Go `instructor.Dashboard` DTO exactly (screen 31's KPIs).
class InstructorDashboard {
  const InstructorDashboard({
    required this.courseCount,
    required this.totalStudents,
    required this.avgRating,
  });

  final int courseCount;
  final int totalStudents;
  final double avgRating;

  factory InstructorDashboard.fromJson(Map<String, dynamic> json) {
    return InstructorDashboard(
      courseCount: json['course_count'] as int,
      totalStudents: json['total_students'] as int,
      avgRating: (json['avg_rating'] as num).toDouble(),
    );
  }
}
