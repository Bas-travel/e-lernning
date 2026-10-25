import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

/// Shows the current account details.
///
/// Saving is intentionally disabled: 05-openapi.yaml has `GET /me` but no
/// endpoint to update the profile, so there is nothing real to call yet.
/// TODO(api): enable "บันทึก" once `PUT /me` exists.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppDependencies.authRepository.currentUser;
    final name = user?.displayName ?? 'Anan Suksawat';
    final email = (user?.email.isNotEmpty ?? false)
        ? user!.email
        : 'learner@ablearning.com';

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            text,
            style: AppTypography.base(12, weight: FontWeight.w600),
          ),
        );

    return SubPageScaffold(
      title: 'Edit Profile',
      children: [
        const SizedBox(height: 8),
        Center(
          child: AppAvatar(
            initial: user?.initial ?? 'A',
            size: 72,
            fontSize: 24,
          ),
        ),
        label('ชื่อที่แสดง'),
        _ValueBox(name),
        label('อีเมล'),
        _ValueBox(email),
        const SizedBox(height: 14),
        Text(
          'ระบบยังไม่รองรับการแก้ไขโปรไฟล์ในเวอร์ชันนี้',
          style: AppTypography.base(11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        const AppButton.primary(label: 'บันทึก', onPressed: null, expand: true),
      ],
    );
  }
}

class _ValueBox extends StatelessWidget {
  const _ValueBox(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.chipBg,
      borderColor: AppColors.border,
      padding: const EdgeInsets.all(11),
      child: Text(value, style: AppTypography.base(13)),
    );
  }
}
