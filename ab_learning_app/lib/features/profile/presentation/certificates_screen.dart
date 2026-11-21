import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import 'profile_sample_data.dart';

/// TODO(api): `GET /certificates`, download via `/certificates/{id}/download`.
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Certificates',
      children: [
        const SizedBox(height: 8),
        for (final c in ProfileSampleData.certificates) ...[
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppGradients.warm,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.workspace_premium, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.course,
                        style: AppTypography.base(13, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ออกเมื่อ ${c.issued} · ${c.code}',
                        style: AppTypography.base(11,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
