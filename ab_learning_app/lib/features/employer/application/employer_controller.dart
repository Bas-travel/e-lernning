import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/employer_repository.dart';
import '../models/employer_dashboard.dart';

final Provider<EmployerRepository> employerRepositoryProvider =
    Provider<EmployerRepository>((ref) {
  return EmployerRepository(apiClient: ref.watch(apiClientProvider));
});

/// Drives screen 39's KPI row. Guarded server-side by
/// RequireRole("EMPLOYER") and scoped to the `employers` row linked to the
/// logged-in account.
final FutureProvider<EmployerDashboard> employerDashboardProvider =
    FutureProvider<EmployerDashboard>((ref) {
  return ref.watch(employerRepositoryProvider).getDashboard();
});

/// Drives screen 39's "Recommended Talent" rail — kept as a separate
/// provider from the dashboard KPIs so a slow candidate-ranking query
/// doesn't block the KPI cards from rendering first.
final FutureProvider<List<TopApplicant>> topApplicantsProvider =
    FutureProvider<List<TopApplicant>>((ref) {
  return ref.watch(employerRepositoryProvider).getTopApplicants();
});
