import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/instructor_repository.dart';
import '../models/instructor_dashboard.dart';

final Provider<InstructorRepository> instructorRepositoryProvider =
    Provider<InstructorRepository>((ref) {
  return InstructorRepository(apiClient: ref.watch(apiClientProvider));
});

/// Drives screen 31. Guarded server-side by RequireRole("INSTRUCTOR") — a
/// non-instructor account never reaches this screen (see app_router.dart),
/// but even if it somehow did, the backend would return 403 and this
/// provider's error state would show, not fabricated data.
final FutureProvider<InstructorDashboard> instructorDashboardProvider =
    FutureProvider<InstructorDashboard>((ref) {
  return ref.watch(instructorRepositoryProvider).getDashboard();
});
