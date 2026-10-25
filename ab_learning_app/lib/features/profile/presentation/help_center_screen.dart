import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

const _faqs = <({String q, String a})>[
  (
    q: 'ลืมรหัสผ่านต้องทำอย่างไร',
    a: 'กด "ลืมรหัสผ่าน" ที่หน้าเข้าสู่ระบบ แล้วกรอกอีเมลเพื่อรับลิงก์ตั้งรหัสผ่านใหม่',
  ),
  (
    q: 'ซื้อคอร์สแล้วเรียนได้นานแค่ไหน',
    a: 'เรียนได้ตลอดชีพตามเงื่อนไขของแต่ละคอร์ส ดูรายละเอียดได้ที่หน้าคอร์ส',
  ),
  (
    q: 'ขอใบประกาศนียบัตรได้เมื่อไร',
    a: 'เมื่อเรียนครบทุกบทและผ่านแบบทดสอบท้ายคอร์ส ใบประกาศจะอยู่ในเมนู Certificates',
  ),
  (
    q: 'ขอคืนเงินได้หรือไม่',
    a: 'ขอคืนเงินได้ภายใน 7 วันหลังซื้อ หากเรียนไม่เกิน 20% ของคอร์ส ติดต่อทีมงานเพื่อดำเนินการ',
  ),
];

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Help Center',
      children: [
        const SectionLabel('คำถามที่พบบ่อย'),
        for (var i = 0; i < _faqs.length; i++) ...[
          AppCard(
            onTap: () => setState(() => _open = _open == i ? null : i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _faqs[i].q,
                        style: AppTypography.base(13, weight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      _open == i ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (_open == i) ...[
                  const SizedBox(height: 8),
                  Text(
                    _faqs[i].a,
                    style: AppTypography.base(
                      12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SectionLabel('ติดต่อทีมงาน'),
        AppCard(
          color: AppColors.primaryTint,
          borderColor: AppColors.primaryTint,
          child: Text(
            'support@ablearning.com\nทุกวัน 09:00–18:00 น.',
            style: AppTypography.base(13, height: 1.5),
          ),
        ),
      ],
    );
  }
}
