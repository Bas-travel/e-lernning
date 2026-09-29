import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Standard "not built yet" screen for destinations whose full feature
/// (real CRUD wired to the Go API) is explicitly scoped to a later phase.
/// Keeps navigation fully wired now so the Role Shell can be demoed end to
/// end, without pretending the deeper feature already exists.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String description;
  final String phaseLabel;
  final IconData icon;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.description,
    this.phaseLabel = 'Phase 3',
    this.icon = Icons.construction_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pillWarnBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Coming in $phaseLabel',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: AppTypography.h1.copyWith(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
