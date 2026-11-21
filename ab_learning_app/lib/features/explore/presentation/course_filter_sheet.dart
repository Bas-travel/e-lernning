import 'package:flutter/material.dart';

import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../data/course_catalog_sample.dart';

/// Bottom sheet for [CourseFilter]. Returns the new filter on "ใช้ตัวกรอง".
Future<CourseFilter?> showCourseFilterSheet(
  BuildContext context,
  CourseFilter current,
) {
  return showModalBottomSheet<CourseFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final CourseFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late PriceBand _price = widget.initial.price;
  late double _rating = widget.initial.minRating;

  static const _ratings = <({String label, double value})>[
    (label: 'ทั้งหมด', value: 0),
    (label: '4.5 ★ ขึ้นไป', value: 4.5),
    (label: '4.8 ★ ขึ้นไป', value: 4.8),
  ];

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          text,
          style: AppTypography.base(12, weight: FontWeight.w600),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ตัวกรอง',
                style: AppTypography.base(16, weight: FontWeight.w700)),
            _title('ราคา'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in PriceBand.values)
                  AppChip(
                    label: b.label,
                    active: b == _price,
                    onTap: () => setState(() => _price = b),
                  ),
              ],
            ),
            _title('คะแนน'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in _ratings)
                  AppChip(
                    label: r.label,
                    active: r.value == _rating,
                    onTap: () => setState(() => _rating = r.value),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: 'ล้าง',
                    onPressed: () =>
                        Navigator.of(context).pop(const CourseFilter()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton.primary(
                    label: 'ใช้ตัวกรอง',
                    onPressed: () => Navigator.of(context)
                        .pop(CourseFilter(price: _price, minRating: _rating)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
