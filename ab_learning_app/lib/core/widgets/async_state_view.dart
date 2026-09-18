import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Renders the Loading / Error / Success states required by
/// `00-blueprint-overview.md` §6 for any [AsyncValue], so each dashboard
/// screen only has to supply its `data` builder — the boring 90% (a
/// skeleton, a retry button) lives here exactly once instead of copy-pasted
/// four times across Instructor/Corporate/Employer/Admin.
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    required this.value,
    required this.data,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const _DashboardLoading(),
      error: (Object error, StackTrace _) => _DashboardError(onRetry: onRetry),
      data: (T value) => data(context, value),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List<Widget>.generate(
          4,
          (_) => Container(
            width: 160,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('โหลดข้อมูลไม่สำเร็จ', style: AppTypography.h2),
            const SizedBox(height: 6),
            const Text(
              'อาจเป็นเพราะสิทธิ์การเข้าถึงหรือการเชื่อมต่อ',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SecondaryButton(label: 'ลองอีกครั้ง', onPressed: onRetry, fullWidth: false),
          ],
        ),
      ),
    );
  }
}
