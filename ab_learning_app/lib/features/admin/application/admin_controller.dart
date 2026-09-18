import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/admin_repository.dart';
import '../models/admin_dashboard.dart';

final Provider<AdminRepository> adminRepositoryProvider =
    Provider<AdminRepository>((ref) {
  return AdminRepository(apiClient: ref.watch(apiClientProvider));
});

/// Drives screen 40. Guarded server-side by RequireRole("ADMIN") — the
/// only dashboard in this codebase with no per-account scoping, since an
/// admin sees the whole platform by definition.
final FutureProvider<AdminDashboard> adminDashboardProvider =
    FutureProvider<AdminDashboard>((ref) {
  return ref.watch(adminRepositoryProvider).getDashboard();
});

/// Drives screen 41's moderation queue.
final FutureProvider<List<PendingCourse>> pendingCoursesProvider =
    FutureProvider<List<PendingCourse>>((ref) {
  return ref.watch(adminRepositoryProvider).getPendingCourses();
});

/// Mutating actions for the Admin domain, kept separate from the read-only
/// providers above. After a successful approve, both [pendingCoursesProvider]
/// (the row disappears) and [adminDashboardProvider] (pending_moderation
/// count drops by one) are invalidated so the UI reflects reality without
/// the caller having to remember to refresh two different providers.
class AdminActions {
  AdminActions(this._ref);
  final Ref _ref;

  Future<void> approveCourse(int id) async {
    await _ref.read(adminRepositoryProvider).approveCourse(id);
    _ref.invalidate(pendingCoursesProvider);
    _ref.invalidate(adminDashboardProvider);
  }
}

final Provider<AdminActions> adminActionsProvider =
    Provider<AdminActions>((ref) => AdminActions(ref));
