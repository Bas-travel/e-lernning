import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/status_pill.dart';
import 'course_back_button.dart';

/// Demo content from `02-hifi-mockups.html` (screen 11).
/// TODO(api): replace with `GET /api/v1/courses/{id}`.
const _courseTitle = 'Go Backend Professional';
const _outcomes = <String>[
  'ออกแบบ REST API ด้วย Go',
  'เชื่อมต่อฐานข้อมูล MySQL',
  'Authentication ด้วย JWT',
  'Deploy สู่ Production',
];

class _LessonRow {
  const _LessonRow(this.prefix, this.title, this.duration, {this.locked = false});

  final String prefix;
  final String title;
  final String duration;
  final bool locked;
}

const _lessons = <_LessonRow>[
  _LessonRow('✓', 'Introduction', '12 min'),
  _LessonRow('▶', 'Go Fundamentals', '1h 20m'),
  _LessonRow('🔒', 'Production Deployment', '40 min', locked: true),
];

// Prototype: all unlocked lessons open the same demo lesson.
const _demoLessonId = 'lesson1';

class HifiCourseDetailScreen extends StatelessWidget {
  /// Route parameter. TODO(api): fetch course data by this id.
  final String courseId;

  const HifiCourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: (_) => const _CourseMobile(),
        desktop: (_) => const _CourseDesktop(),
      ),
    );
  }
}

// ---------------------------------------------------------------- mobile

class _CourseMobile extends StatelessWidget {
  const _CourseMobile();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: CenteredContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(gradient: AppGradients.brand),
                    child: const SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: CourseBackButton(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _courseTitle,
                          style: AppTypography.base(17, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '⭐ 4.9 (2,140) · 8,421 students · Dr. Krit',
                          style: AppTypography.base(
                            12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const _PriceRow(
                          priceSize: 22,
                          discountLabel: '-40%',
                          oldPriceSize: 13,
                        ),
                        const SizedBox(height: 16),
                        const _SectionHeading('สิ่งที่คุณจะได้เรียนรู้'),
                        Text(
                          [for (final o in _outcomes) '✓ $o'].join('\n'),
                          style: AppTypography.base(
                            12.5,
                            color: AppColors.textSecondary,
                            height: 1.8,
                          ),
                        ),
                        const _SectionHeading('หลักสูตร'),
                        for (var i = 0; i < _lessons.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          _CurriculumCard(
                            lesson: _lessons[i],
                            durationSize: 11,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Sticky bottom CTA
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CenteredContent(
                child: AppButton.primary(
                  label: 'ซื้อคอร์สนี้เลย — ฿2,990',
                  onPressed: () => context.push('/checkout/${widget.courseId}'),
                  expand: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------- desktop

class _CourseDesktop extends StatelessWidget {
  const _CourseDesktop();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        gradient: AppGradients.brand,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Align(
                        alignment: Alignment.topLeft,
                        child: CourseBackButton(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _courseTitle,
                      style: AppTypography.base(24, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '⭐ 4.9 (2,140 รีวิว) · 8,421 students · สอนโดย Dr. Krit',
                      style: AppTypography.base(
                        13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _SectionHeading('สิ่งที่คุณจะได้เรียนรู้'),
                    CardGrid(
                      columns: 3,
                      children: [
                        for (final o in _outcomes.take(3))
                          AppCard(
                            child: Text(
                              '✓ $o',
                              style: AppTypography.base(
                                12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const _SectionHeading('หลักสูตร'),
                    for (var i = 0; i < _lessons.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _CurriculumCard(lesson: _lessons[i], durationSize: 11.5),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 32),
            SizedBox(
              width: 320,
              child: const SingleChildScrollView(child: _PurchaseCard()),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard();

  @override
  Widget build(BuildContext context) {
    final infoStyle = AppTypography.base(
      12,
      color: AppColors.textSecondary,
      height: 2,
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '฿2,990',
                style: AppTypography.base(
                  24,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '฿4,990',
                style: AppTypography.base(
                  13,
                  color: AppColors.textSecondary,
                ).copyWith(decoration: TextDecoration.lineThrough),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const StatusPill(
            label: 'ประหยัด 40%',
            variant: StatusPillVariant.error,
          ),
          const SizedBox(height: 16),
          // TODO(nav): no Cart screen yet, so "เพิ่มลงตะกร้า" stays inactive.
          AppButton.primary(
            label: 'ซื้อคอร์สนี้เลย',
            onPressed: () => context.push('/checkout/${widget.courseId}'),
            expand: true,
          ),
          const SizedBox(height: 8),
          AppButton.secondary(
            label: 'เพิ่มลงตะกร้า',
            onPressed: () {},
            expand: true,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Text(
              '📹 18h 30m วิดีโอ\n📄 42 บทเรียน\n🏆 ใบเกียรติบัตรเมื่อจบหลักสูตร',
              style: infoStyle,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- shared

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(text, style: AppTypography.base(14, weight: FontWeight.w600)),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.priceSize,
    required this.discountLabel,
    required this.oldPriceSize,
  });

  final double priceSize;
  final String discountLabel;
  final double oldPriceSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '฿2,990',
          style: AppTypography.base(
            priceSize,
            weight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '฿4,990',
          style: AppTypography.base(
            oldPriceSize,
            color: AppColors.textSecondary,
          ).copyWith(decoration: TextDecoration.lineThrough),
        ),
        const SizedBox(width: 8),
        StatusPill(label: discountLabel, variant: StatusPillVariant.error),
      ],
    );
  }
}

class _CurriculumCard extends StatelessWidget {
  const _CurriculumCard({required this.lesson, required this.durationSize});

  final _LessonRow lesson;
  final double durationSize;

  @override
  Widget build(BuildContext context) {
    final color = lesson.locked ? AppColors.textSecondary : AppColors.text;
    return AppCard(
      // Spec 12: tapping an unlocked lesson row navigates straight to the player.
      onTap: lesson.locked
          ? null
          : () => context.push('/player/$_demoLessonId'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${lesson.prefix} ${lesson.title}',
              style: AppTypography.base(13, color: color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            lesson.duration,
            style: AppTypography.base(
              durationSize,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
