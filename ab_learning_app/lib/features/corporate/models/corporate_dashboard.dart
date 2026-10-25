/// Mirrors the Go `corporate.Dashboard` DTO exactly (screen 36's KPIs).
class CorporateDashboard {
  const CorporateDashboard({
    required this.organizationName,
    required this.employeeCount,
    required this.registeredEmployees,
    required this.trainingBudget,
    required this.activeLearners,
    required this.completionRatePct,
  });

  final String organizationName;
  final int employeeCount;
  final int registeredEmployees;
  final double trainingBudget;
  final int activeLearners;
  final double completionRatePct;

  factory CorporateDashboard.fromJson(Map<String, dynamic> json) {
    return CorporateDashboard(
      organizationName: json['organization_name'] as String,
      employeeCount: json['employee_count'] as int,
      registeredEmployees: json['registered_employees'] as int,
      trainingBudget: (json['training_budget'] as num).toDouble(),
      activeLearners: json['active_learners'] as int,
      completionRatePct: (json['completion_rate_pct'] as num).toDouble(),
    );
  }
}
