import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// Inline error banner shown above forms (spec: "Error — inline banner").
class InlineBanner extends StatelessWidget {
  const InlineBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.pillErrorBg,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.pillErrorFg,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.base(
                  12,
                  color: AppColors.pillErrorFg,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
