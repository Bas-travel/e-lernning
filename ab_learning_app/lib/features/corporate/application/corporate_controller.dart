import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/corporate_repository.dart';
import '../models/corporate_dashboard.dart';

final Provider<CorporateRepository> corporateRepositoryProvider =
    Provider<CorporateRepository>((ref) {
  return CorporateRepository(apiClient: ref.watch(apiClientProvider));
});

/// Drives screen 36. Guarded server-side by
/// RequireRole("CORP_ADMIN", "CORP_MANAGER") and scoped to whichever
/// organization the logged-in account belongs to via `organization_users`
/// — see `internal/corporate/repository.go` on the Go side.
final FutureProvider<CorporateDashboard> corporateDashboardProvider =
    FutureProvider<CorporateDashboard>((ref) {
  return ref.watch(corporateRepositoryProvider).getDashboard();
});
