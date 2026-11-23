import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/status_pill.dart';
import '../../catalog/data/catalog_repository.dart';
import 'course_back_button.dart';
import 'course_content.dart';

class HifiCourseDetailScreen extends StatefulWidget {
  /// Route parameter: a numeric id loads from the API, anything else (the
  /// bundled `go-backend` slug) shows the sample content.
  final String courseId;

  const HifiCourseDetailScreen({super.key, required this.courseId});

  @override
  State<HifiCourseDetailScreen> createState() => _HifiCourseDetailScreenState();
}

class _HifiCourseDetailScreenState extends State<HifiCourseDetailScreen> {
  CourseContent? _content;

  @override
  void initState() {
    super.initState();
    final repo = AppDependencies.catalogRepository;
    if (repo.bundledOnly) {
      _content = CourseContent.sample();
    } else {
      _load(repo);
    }
  }

  /// Falls back to the bundled demo content when the server has nothing for
  /// this id (slug id, offline, 404/5xx), so the screen is never blank.
  Future<void> _load(CatalogRepository repo) async {
    final course = await repo.course(widget.courseId);
    final sections =
        course == null ? null : await repo.curriculum(widget.courseId);
    if (!mounted) return;
    setState(() {
      _content = course == null
          ? CourseContent.sample()
          : CourseContent.fromApi(course, sections ?? const []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    if (content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final courseId = widget.courseId;
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: (_) => _CourseMobile(courseId: courseId, content: content),
        desktop: (_) => _CourseDesktop(courseId: courseId, content: content),
      ),
    );
  }
}

// ---------------------------------------------------------------- mobile

class _CourseMobile extends StatelessWidget {
  final String courseId;
  final CourseContent content;

  const _CourseMobile({required this.courseId, required this.content});

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
                    decoration:
                        const BoxDecoration(gradient: AppGradients.brand),
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
                          content.title,
                          style:
                              AppTypography.base(17, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          content.metaMobile,
                          style: AppTypography.base(
                            12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PriceRow(
                          priceSize: 22,
                          priceLabel: content.priceLabel,
                          oldPriceLabel: content.oldPriceLabel,
                          discountLabel: content.discountBadge,
                          oldPriceSize: 13,
                        ),
                        const SizedBox(height: 16),
                        if (content.outcomes.isNotEmpty) ...[
                          const _SectionHeading('สิ่งที่คุณจะได้เรียนรู้'),
                          Text(
                            [for (final o in content.outcomes) '✓ $o']
                                .join('\n'),
                            style: AppTypography.base(
                              12.5,
                              color: AppColors.textSecondary,
                              height: 1.8,
                            ),
                          ),
                        ],
                        const _SectionHeading('หลักสูตร'),
                        for (var i = 0; i < content.lessons.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          _CurriculumCard(
                            lesson: content.lessons[i],
                            durationSize: 11,
                          ),
                        ],
                        _ReviewsLink(courseId: courseId),
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
                  label: 'ซื้อคอร์สนี้เลย — ${content.priceLabel}',
                  onPressed: () => context.push('/checkout/$courseId'),
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
  final String courseId;
  final CourseContent content;

  const _CourseDesktop({required this.courseId, required this.content});

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
                      content.title,
                      style: AppTypography.base(24, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.metaDesktop,
                      style: AppTypography.base(
                        13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (content.outcomes.isNotEmpty) ...[
                      const _SectionHeading('สิ่งที่คุณจะได้เรียนรู้'),
                      CardGrid(
                        columns: 3,
                        children: [
                          for (final o in content.outcomes.take(3))
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
                    ],
                    const _SectionHeading('หลักสูตร'),
                    for (var i = 0; i < content.lessons.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _CurriculumCard(
                        lesson: content.lessons[i],
                        durationSize: 11.5,
                      ),
                    ],
                    _ReviewsLink(courseId: courseId),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 32),
            SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: _PurchaseCard(courseId: courseId, content: content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final String courseId;
  final CourseContent content;

  const _PurchaseCard({required this.courseId, required this.content});

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
                content.priceLabel,
                style: AppTypography.base(
                  24,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (content.oldPriceLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  content.oldPriceLabel!,
                  style: AppTypography.base(
                    13,
                    color: AppColors.textSecondary,
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
              ],
            ],
          ),
          if (content.savingsBadge != null) ...[
            const SizedBox(height: 4),
            StatusPill(
              label: content.savingsBadge!,
              variant: StatusPillVariant.error,
            ),
          ],
          const SizedBox(height: 16),
          // TODO(nav): no Cart screen yet, so "เพิ่มลงตะกร้า" stays inactive.
          AppButton.primary(
            label: 'ซื้อคอร์สนี้เลย',
            onPressed: () => context.push('/checkout/$courseId'),
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
            child: Text(content.infoLines, style: infoStyle),
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
    required this.priceLabel,
    required this.oldPriceLabel,
    required this.discountLabel,
    required this.oldPriceSize,
  });

  final double priceSize;
  final String priceLabel;
  final String? oldPriceLabel;
  final String? discountLabel;
  final double oldPriceSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          priceLabel,
          style: AppTypography.base(
            priceSize,
            weight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (oldPriceLabel != null) ...[
          const SizedBox(width: 8),
          Text(
            oldPriceLabel!,
            style: AppTypography.base(
              oldPriceSize,
              color: AppColors.textSecondary,
            ).copyWith(decoration: TextDecoration.lineThrough),
          ),
        ],
        if (discountLabel != null) ...[
          const SizedBox(width: 8),
          StatusPill(
            label: discountLabel!,
            variant: StatusPillVariant.error,
          ),
        ],
      ],
    );
  }
}

class _CurriculumCard extends StatelessWidget {
  const _CurriculumCard({required this.lesson, required this.durationSize});

  final CourseLessonRow lesson;
  final double durationSize;

  @override
  Widget build(BuildContext context) {
    final color = lesson.locked ? AppColors.textSecondary : AppColors.text;
    return AppCard(
      // Spec 12: tapping an unlocked lesson row navigates straight to the player.
      onTap: lesson.locked
          ? null
          : () => context.push('/player/${lesson.lessonId}'),
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

/// Opens the reviews page. Only shown for courses that exist on the server
/// (numeric id, online), since the bundled demo courses have no reviews.
class _ReviewsLink extends StatelessWidget {
  const _ReviewsLink({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    if (AppDependencies.catalogRepository.bundledOnly ||
        int.tryParse(courseId) == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppButton.secondary(
        label: 'รีวิวและให้คะแนนคอร์ส',
        onPressed: () => context.push('/course/$courseId/reviews'),
        expand: true,
      ),
    );
  }
}
