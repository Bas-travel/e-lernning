import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import '../../explore/data/course_catalog_sample.dart';

const _methods = <({String key, String label})>[
  (key: 'promptpay', label: 'PromptPay'),
  (key: 'card', label: 'บัตรเครดิต / เดบิต'),
  (key: 'wallet', label: 'Wallet'),
];

/// Order summary + payment method + confirm.
///
/// Prototype only: nothing is charged. `POST /orders` takes integer course ids
/// while the app still uses slug ids, so the real calls are not wired yet.
/// TODO(api): `POST /orders` then `POST /payments` once ids line up.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.courseId});

  final String courseId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _method = _methods.first.key;
  bool _paid = false;

  CatalogCourse? get _course {
    for (final c in [
      ...CourseCatalogSample.all,
      ...CourseCatalogSample.searchable,
    ]) {
      if (c.id == widget.courseId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;
    final title = course?.title ?? 'Go Backend Masterclass';
    final price = course?.price ?? '฿2,990';

    if (_paid) {
      return SubPageScaffold(
        title: 'ชำระเงิน',
        fallbackRoute: '/home',
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 12),
          Text(
            'ทำรายการสำเร็จ (โหมดทดสอบ)',
            textAlign: TextAlign.center,
            style: AppTypography.base(16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'ยังไม่มีการตัดเงินจริง',
            textAlign: TextAlign.center,
            style: AppTypography.base(12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            label: 'ไปที่ My Learning',
            onPressed: () => context.go('/learn'),
            expand: true,
          ),
        ],
      );
    }

    return SubPageScaffold(
      title: 'ชำระเงิน',
      fallbackRoute: '/course/${widget.courseId}',
      bottom: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: AppButton.primary(
          label: 'ยืนยันชำระเงิน — $price',
          onPressed: () => setState(() => _paid = true),
          expand: true,
        ),
      ),
      children: [
        const SectionLabel('รายการสั่งซื้อ'),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.base(13, weight: FontWeight.w600),
                ),
              ),
              Text(price,
                  style: AppTypography.base(13, weight: FontWeight.w700)),
            ],
          ),
        ),
        const SectionLabel('วิธีชำระเงิน'),
        for (final m in _methods) ...[
          AppCard(
            onTap: () => setState(() => _method = m.key),
            borderColor:
                _method == m.key ? AppColors.primary : AppColors.cardBorder,
            child: Row(
              children: [
                Expanded(
                  child: Text(m.label, style: AppTypography.base(13)),
                ),
                Icon(
                  _method == m.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: _method == m.key
                      ? AppColors.primary
                      : AppColors.textSecondary,
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
