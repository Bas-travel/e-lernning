import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';
import 'course_back_button.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final course = MockRepository.courseById(courseId);
    final isEnrolled = MockRepository.isEnrolled(courseId);
    final sections = MockRepository.curriculumFor(courseId);

    return Scaffold(
      body: ResponsiveBuilder(
        mobile: (_) => _CourseMobile(
          course: course,
          sections: sections,
          isEnrolled: isEnrolled,
        ),
        desktop: (_) => _CourseDesktop(
          course: course,
          sections: sections,
          isEnrolled: isEnrolled,
        ),
      ),
    );
  }
}

class _CourseMobile extends StatelessWidget {
  final Course course;
  final List<CourseSection> sections;
  final bool isEnrolled;

  const _CourseMobile({
    required this.course,
    required this.sections,
    required this.isEnrolled,
  });

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
                    decoration: const BoxDecoration(
                      gradient: AppGradients.brand,
                    ),
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
                        _CourseInformation(course: course),
                        const _SectionHeading('รายละเอียดหลักสูตร'),
                        Text(
                          course.description,
                          style: AppTypography.base(
                            12.5,
                            color: AppColors.textSecondary,
                            height: 1.8,
                          ),
                        ),
                        const _SectionHeading('สิ่งที่คุณจะได้เรียนรู้'),
                        _LearningOutcomes(outcomes: course.whatYouLearn),
                        const _SectionHeading('หลักสูตร'),
                        _CurriculumList(
                          sections: sections,
                          isEnrolled: isEnrolled,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: CenteredContent(
                child: _CourseActionButton(
                  course: course,
                  isEnrolled: isEnrolled,
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

class _CourseDesktop extends StatelessWidget {
  final Course course;
  final List<CourseSection> sections;
  final bool isEnrolled;

  const _CourseDesktop({
    required this.course,
    required this.sections,
    required this.isEnrolled,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 28,
        ),
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
                    _CourseInformation(course: course),
                    const _SectionHeading('รายละเอียดหลักสูตร'),
                    Text(
                      course.description,
                      style: AppTypography.base(
                        13,
                        color: AppColors.textSecondary,
                        height: 1.8,
                      ),
                    ),
                    const _SectionHeading('สิ่งที่คุณจะได้เรียนรู้'),
                    CardGrid(
                      columns: 3,
                      children: [
                        for (final outcome in course.whatYouLearn)
                          AppCard(
                            child: Text(
                              '✓ $outcome',
                              style: AppTypography.base(
                                12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const _SectionHeading('หลักสูตร'),
                    _CurriculumList(
                      sections: sections,
                      isEnrolled: isEnrolled,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 32),
            SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: _PurchaseCard(
                  course: course,
                  isEnrolled: isEnrolled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseInformation extends StatelessWidget {
  final Course course;

  const _CourseInformation({required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: AppTypography.base(
            22,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '⭐ ${course.rating} · ${course.students} students · '
          'สอนโดย ${course.instructor}',
          style: AppTypography.base(
            13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _PriceRow(
          price: course.priceLabel,
          oldPrice: course.originalPriceLabel,
          priceSize: 22,
          oldPriceSize: 13,
        ),
      ],
    );
  }
}

class _LearningOutcomes extends StatelessWidget {
  final List<String> outcomes;

  const _LearningOutcomes({required this.outcomes});

  @override
  Widget build(BuildContext context) {
    return Text(
      [for (final outcome in outcomes) '✓ $outcome'].join('\n'),
      style: AppTypography.base(
        12.5,
        color: AppColors.textSecondary,
        height: 1.8,
      ),
    );
  }
}

class _CurriculumList extends StatelessWidget {
  final List<CourseSection> sections;
  final bool isEnrolled;

  const _CurriculumList({
    required this.sections,
    required this.isEnrolled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              section.title,
              style: AppTypography.base(
                13,
                weight: FontWeight.w600,
              ),
            ),
          ),
          for (final lesson in section.lessons) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CurriculumCard(
                lesson: lesson,
                isEnrolled: isEnrolled,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _CurriculumCard extends StatelessWidget {
  final LessonItem lesson;
  final bool isEnrolled;

  const _CurriculumCard({
    required this.lesson,
    required this.isEnrolled,
  });

  @override
  Widget build(BuildContext context) {
    final locked = lesson.state == LessonState.locked || !isEnrolled;
    final color = locked ? AppColors.textSecondary : AppColors.text;

    final prefix = switch (lesson.state) {
      LessonState.completed => '✓',
      LessonState.inProgress => '▶',
      LessonState.locked => '🔒',
    };

    return AppCard(
      onTap: locked
          ? null
          : () {
              if (lesson.hasQuiz) {
                context.push('/quiz/${lesson.id}');
              } else {
                context.push('/player/${lesson.id}');
              }
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$prefix ${lesson.title}',
              style: AppTypography.base(
                13,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            lesson.duration,
            style: AppTypography.base(
              11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseActionButton extends StatelessWidget {
  final Course course;
  final bool isEnrolled;
  final bool expand;

  const _CourseActionButton({
    required this.course,
    required this.isEnrolled,
    required this.expand,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: isEnrolled ? 'เรียนต่อ' : 'ซื้อคอร์สนี้เลย — ${course.priceLabel}',
      onPressed: () {
        if (isEnrolled) {
          context.push('/course/${course.id}/curriculum');
        } else {
          context.push(
            '/checkout/${course.id}',
            extra: course.title,
          );
        }
      },
      expand: expand,
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Course course;
  final bool isEnrolled;

  const _PurchaseCard({
    required this.course,
    required this.isEnrolled,
  });

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
          _PriceRow(
            price: course.priceLabel,
            oldPrice: course.originalPriceLabel,
            priceSize: 24,
            oldPriceSize: 13,
          ),
          const SizedBox(height: 12),
          if (!isEnrolled)
            const StatusPill(
              label: 'ราคาพิเศษ',
              variant: StatusPillVariant.error,
            )
          else
            const StatusPill(
              label: 'ลงทะเบียนแล้ว',
              variant: StatusPillVariant.success,
            ),
          const SizedBox(height: 16),
          _CourseActionButton(
            course: course,
            isEnrolled: isEnrolled,
            expand: true,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: Text(
              '📄 ${course.totalLessons} บทเรียน\n'
              '✓ เรียนแล้ว ${course.completedLessons} บทเรียน\n'
              '🏆 ใบเกียรติบัตรเมื่อจบหลักสูตร',
              style: infoStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Text(
        text,
        style: AppTypography.base(
          14,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.price,
    required this.oldPrice,
    required this.priceSize,
    required this.oldPriceSize,
  });

  final String price;
  final String? oldPrice;
  final double priceSize;
  final double oldPriceSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          price,
          style: AppTypography.base(
            priceSize,
            weight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (oldPrice != null) ...[
          const SizedBox(width: 8),
          Text(
            oldPrice!,
            style: AppTypography.base(
              oldPriceSize,
              color: AppColors.textSecondary,
            ).copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}
