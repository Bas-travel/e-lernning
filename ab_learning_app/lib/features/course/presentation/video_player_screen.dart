import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/responsive.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';
import 'course_back_button.dart';

const _tabs = <String>[
  'Resources',
  'Notes',
  'Discussion',
  'Ask AI ✨',
];

class VideoPlayerScreen extends StatefulWidget {
  final String lessonId;

  const VideoPlayerScreen({super.key, required this.lessonId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  int _tab = 0;

  LessonItem? get _lesson => MockRepository.lessonById(widget.lessonId);

  LessonItem? get _nextLesson =>
      MockRepository.nextLessonAfter(widget.lessonId);

  Future<void> _completeAndAdvance() async {
    final lesson = _lesson;

    if (lesson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบบทเรียนที่ต้องการ')),
      );
      return;
    }

    MockRepository.completeLesson(widget.lessonId);

    final next = MockRepository.nextLessonAfter(widget.lessonId);

    if (!mounted) return;

    if (next == null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('เรียนครบทุกบทแล้ว!'),
          content: const Text('คุณเรียนครบทุกบทเรียนในหลักสูตรนี้แล้ว'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.pop();
              },
              child: const Text('กลับไปหน้าก่อนหน้า'),
            ),
          ],
        ),
      );
      return;
    }

    if (next.hasQuiz) {
      context.push('/quiz/${next.id}');
    } else {
      context.push('/player/${next.id}');
    }
  }

  void _openTutor() {
    context.push('/tutor');
  }

  Widget _tabContent() {
    if (_tab == 3) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Tutor',
              style: AppTypography.base(14, weight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'มีคำถามเกี่ยวกับบทเรียนนี้หรือไม่?',
              style: AppTypography.base(
                12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            AppButton.primary(
              label: 'ถาม AI Tutor',
              onPressed: _openTutor,
            ),
          ],
        ),
      );
    }

    if (_tab != 0) {
      return AppCard(
        child: Text(
          'ยังไม่มีข้อมูลในแท็บนี้',
          style: AppTypography.base(
            12.5,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return AppCard(
      child: SizedBox(
        width: double.infinity,
        child: Text(
          'ยังไม่มีเอกสารประกอบบทเรียนนี้',
          style: AppTypography.base(
            12.5,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AppChip(
              label: _tabs[i],
              active: i == _tab,
              onTap: () {
                setState(() => _tab = i);
                if (i == 3) _openTutor();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoPreview({double iconSize = 36}) {
    return Semantics(
      label: 'Video player, lesson ${widget.lessonId}',
      child: Container(
        color: AppColors.playerSurface,
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.play_arrow,
                size: iconSize,
                color: Colors.white,
              ),
            ),
            const SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: CourseBackButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final lesson = _lesson;
    final next = _nextLesson;

    if (lesson == null) {
      return _buildNotFound();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: CenteredContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 210,
                    child: _buildVideoPreview(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: AppTypography.base(
                            14,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'บทเรียน ${lesson.id} · ${lesson.duration}'
                          '${next == null ? '' : ' · ถัดไป: ${next.title}'}',
                          style: AppTypography.base(
                            11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTabs(),
                        const SizedBox(height: 14),
                        _tabContent(),
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
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: CenteredContent(
                child: AppButton.primary(
                  label: next == null
                      ? 'เรียนจบบทเรียนนี้'
                      : next.hasQuiz
                          ? 'ทำแบบทดสอบ: ${next.title} →'
                          : 'บทเรียนถัดไป: ${next.title} →',
                  onPressed: _completeAndAdvance,
                  expand: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final lesson = _lesson;
    final next = _nextLesson;

    if (lesson == null) {
      return _buildNotFound();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: AppColors.playerSurface,
            child: Column(
              children: [
                Expanded(
                  child: _buildVideoPreview(iconSize: 52),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  color: AppColors.playerSurface,
                  child: Row(
                    children: [
                      AppChip(
                        label: 'Transcript',
                        active: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      const SizedBox(width: 12),
                      AppChip(
                        label: 'Notes',
                        active: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                      const SizedBox(width: 12),
                      AppChip(
                        label: 'Discussion',
                        active: _tab == 2,
                        onTap: () => setState(() => _tab = 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 360,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Course Curriculum',
                    style: AppTypography.base(
                      14,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const AppProgressBar(value: 0.0),
                  const SizedBox(height: 10),
                  Text(
                    lesson.title,
                    style: AppTypography.base(
                      11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '▶ ${lesson.title}',
                          style: AppTypography.base(
                            12.5,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${lesson.duration} · กำลังเรียน',
                          style: AppTypography.base(
                            11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 8),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            next.title,
                            style: AppTypography.base(12.5),
                          ),
                          Text(
                            next.hasQuiz ? 'แบบทดสอบ' : next.duration,
                            style: AppTypography.base(
                              11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _tabContent(),
                  const SizedBox(height: 16),
                  AppButton.primary(
                    label: next == null
                        ? 'เรียนจบบทเรียนนี้'
                        : next.hasQuiz
                            ? 'ทำแบบทดสอบถัดไป →'
                            : 'บทเรียนถัดไป →',
                    onPressed: _completeAndAdvance,
                    expand: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 42),
            const SizedBox(height: 12),
            const Text('ไม่พบบทเรียนนี้'),
            const SizedBox(height: 12),
            AppButton.secondary(
              label: 'ย้อนกลับ',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: _buildMobile,
        desktop: _buildDesktop,
      ),
    );
  }
}
