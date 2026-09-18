/// Mirrors the Go `employer.Dashboard` DTO exactly (screen 39's KPIs).
class EmployerDashboard {
  const EmployerDashboard({
    required this.companyName,
    required this.openJobs,
    required this.totalApplications,
    required this.shortlistedCount,
    required this.hiredCount,
  });

  final String companyName;
  final int openJobs;
  final int totalApplications;
  final int shortlistedCount;
  final int hiredCount;

  factory EmployerDashboard.fromJson(Map<String, dynamic> json) {
    return EmployerDashboard(
      companyName: json['company_name'] as String,
      openJobs: json['open_jobs'] as int,
      totalApplications: json['total_applications'] as int,
      shortlistedCount: json['shortlisted_count'] as int,
      hiredCount: json['hired_count'] as int,
    );
  }
}

/// Mirrors the Go `employer.TopApplicant` DTO — screen 39's "Recommended
/// Talent" rail.
class TopApplicant {
  const TopApplicant({
    required this.userId,
    required this.name,
    required this.headline,
    required this.matchScore,
    required this.jobTitle,
  });

  final int userId;
  final String name;
  final String headline;
  final double matchScore;
  final String jobTitle;

  factory TopApplicant.fromJson(Map<String, dynamic> json) {
    return TopApplicant(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      headline: json['headline'] as String,
      matchScore: (json['match_score'] as num).toDouble(),
      jobTitle: json['job_title'] as String,
    );
  }
}
