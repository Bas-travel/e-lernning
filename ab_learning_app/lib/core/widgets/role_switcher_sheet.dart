import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/current_user.dart';
import '../../data/mock/models.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// Lets QA / stakeholders jump between roles without needing five separate
/// backend accounts. Once real auth exists, this becomes a dev-only tool
/// (or is removed) rather than the primary way to reach a role.
Future<void> showRoleSwitcherSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Switch role', style: AppTypography.h1.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              'Demo helper — no separate login needed per role yet.',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            for (final role in UserRole.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: role == CurrentUser.role
                      ? AppColors.primary
                      : AppColors.cardBorder,
                  child: Icon(
                    _iconFor(role),
                    color: role == CurrentUser.role ? Colors.white : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
                title: Text(role.label, style: AppTypography.body),
                trailing: role == CurrentUser.role
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  if (role == CurrentUser.role) return;
                  CurrentUser.loginAs(role);
                  context.go(CurrentUser.homeRouteFor(role));
                },
              ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.pillErrorBg,
                child: Icon(Icons.logout, color: AppColors.error, size: 18),
              ),
              title: Text('Logout', style: AppTypography.body.copyWith(color: AppColors.error)),
              onTap: () {
                Navigator.of(context).pop();
                CurrentUser.logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _iconFor(UserRole role) {
  switch (role) {
    case UserRole.learner:
      return Icons.school_outlined;
    case UserRole.instructor:
      return Icons.cast_for_education_outlined;
    case UserRole.corpAdmin:
    case UserRole.corpManager:
      return Icons.apartment_outlined;
    case UserRole.employer:
      return Icons.work_outline;
    case UserRole.admin:
      return Icons.admin_panel_settings_outlined;
  }
}
