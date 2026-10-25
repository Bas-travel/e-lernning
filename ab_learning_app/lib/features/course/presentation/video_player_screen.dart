import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/responsive.dart';
import 'course_back_button.dart';

/// Demo content from `02-hifi-mockups.html` (screen 13).
/// TODO(api): replace with `GET /api/v1/lessons/{id}`.
const _lessonTitle = 'REST API with Go';
const _nextLessonTitle = 'JWT Authentication';
const _tabs = <String>['Resources', 'Notes', 'Discussion', 'Ask AI ✨'];

class VideoPlayerScreen extends StatefulWidget {
  final String lessonId;

  const VideoPlayerScreen({super.key, required this.lessonId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: _buildMobile,
        desktop: _buildDesktop,
      ),
    );
  }

  Widget _tabContent() {
    if (_tab != 0) {
      return AppCard(
        child: Text(
          'ยังไม่มีข้อมูลในแท็บนี้',
          style: AppTypography.base(12.5, color: AppColors.textSecondary),
        ),
      );
    }
    return AppCard(
      child: SizedBox(
        width: double.infinity,
        child: Text(
          '📎 slides-rest-api.pdf\n📎 source-code.zip',
          style: AppTypography.base(12.5, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: CenteredContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label: 'Video player, lesson ${widget.lessonId}',
                    child: Container(
                      height: 210,
                      color: AppColors.playerSurface,
                      child: Stack(
                        children: const [
                          Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          SafeArea(
                            bottom: false,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: CourseBackButton(),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          _lessonTitle,
                          style: AppTypography.base(14, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'บทเรียนที่ 8 · 24:35 · ถัดไป: $_nextLessonTitle',
                          style: AppTypography.base(
                            11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < _tabs.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                AppChip(
                                  label: _tabs[i],
                                  active: i == _tab,
                                  onTap: () => setState(() => _tab = i),
                                ),
                              ],
                            ],
                          ),
                        ),
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
        // Sticky "Next lesson" bar
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
                  label: 'บทเรียนถัดไป: $_nextLessonTitle →',
                  // TODO(api): next lesson id comes from the lesson response.
                  onPressed: () {},
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: AppColors.playerSurface,
            child: Column(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Video player, lesson ${widget.lessonId}',
                    child: Stack(
                      children: const [
                        Center(
                          child: Icon(
                            Icons.play_arrow,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: CourseBackButton(),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      for (final (i, label)
                          in const ['Transcript', 'Notes', 'Discussion'].indexed) ...[
                        if (i > 0) const SizedBox(width: 16),
                        i == 0
                            ? AppChip(label: label, active: true)
                            : Text(
                                label,
                                style: AppTypography.base(
                                  12.5,
                                  color: AppColors.textOnDarkMuted,
                                ),
                              ),
                      ],
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
                    'Go Backend Professional',
                    style: AppTypography.base(14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const AppProgressBar(value: 0.68),
                  const SizedBox(height: 10),
                  Text(
                    '68% เสร็จแล้ว',
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
                          '▶ $_lessonTitle',
                          style: AppTypography.base(12.5, weight: FontWeight.w600),
                        ),
                        Text(
                          '24:35 · กำลังเล่น',
                          style: AppTypography.base(
                            11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nextLessonTitle, style: AppTypography.base(12.5)),
                        Text(
                          '18:02',
                          style: AppTypography.base(
                            11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔒 Production Deployment',
                          style: AppTypography.base(
                            12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '40:00',
                          style: AppTypography.base(
                            11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
