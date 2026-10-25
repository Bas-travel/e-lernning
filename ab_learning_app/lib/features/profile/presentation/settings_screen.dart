import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

/// Settings. Values live in memory only.
/// TODO(api): persist preferences (no settings endpoint in 05-openapi.yaml).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _email = false;
  bool _autoplay = true;
  bool _wifiOnly = true;

  Widget _switchRow(
      String label, String hint, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.base(13, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                hint,
                style: AppTypography.base(11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Settings',
      children: [
        const SectionLabel('การแจ้งเตือน'),
        AppCard(
          child: Column(
            children: [
              _switchRow('Push notification', 'เตือนบทเรียนและไลฟ์สด', _push,
                  (v) => setState(() => _push = v)),
              const Divider(height: 20),
              _switchRow('อีเมลสรุปรายสัปดาห์', 'ความคืบหน้าและคอร์สแนะนำ',
                  _email, (v) => setState(() => _email = v)),
            ],
          ),
        ),
        const SectionLabel('การเรียน'),
        AppCard(
          child: Column(
            children: [
              _switchRow('เล่นบทถัดไปอัตโนมัติ', 'ต่อวิดีโอเมื่อจบบทเรียน',
                  _autoplay, (v) => setState(() => _autoplay = v)),
              const Divider(height: 20),
              _switchRow('ดาวน์โหลดผ่าน Wi-Fi เท่านั้น', 'ประหยัดแพ็กเกจเน็ต',
                  _wifiOnly, (v) => setState(() => _wifiOnly = v)),
            ],
          ),
        ),
        const SectionLabel('ทั่วไป'),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ภาษา',
                  style: AppTypography.base(13, weight: FontWeight.w600)),
              Text(
                'ไทย',
                style: AppTypography.base(13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('เวอร์ชันแอป',
                  style: AppTypography.base(13, weight: FontWeight.w600)),
              Text(
                '1.0.0',
                style: AppTypography.base(13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
