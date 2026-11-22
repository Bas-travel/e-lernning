import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/responsive.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/catalog_repository.dart';
import 'course_back_button.dart';

/// Demo content from `02-hifi-mockups.html` (screen 13), used for slug ids
/// and when the server has nothing for a numeric id.
const _lessonTitle = 'REST API with Go';
const _nextLessonTitle = 'JWT Authentication';
const _tabs = <String>['Resources', 'Notes', 'Discussion', 'Ask AI ✨'];

class HifiVideoPlayerScreen extends StatefulWidget {
  final String lessonId;

  const HifiVideoPlayerScreen({super.key, required this.lessonId});

  @override
  State<HifiVideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<HifiVideoPlayerScreen> {
  int _tab = 0;

  /// Server data for a numeric lesson id (null for the bundled demo lessons).
  LessonDetail? _detail;

  /// Every lesson of the same course, in order, for "next lesson".
  List<CatalogLesson> _siblings = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final repo = AppDependencies.catalogRepository;
    if (!repo.bundledOnly &&
        ApiCatalogRepository.numericId(widget.lessonId) != null) {
      _loading = true;
      _loadFromApi(repo);
    }
  }

  /// Falls back to the bundled demo lesson when the server has nothing.
  Future<void> _loadFromApi(CatalogRepository repo) async {
    final detail = await repo.lesson(widget.lessonId);
    final sections =
        detail == null ? null : await repo.curriculum('${detail.courseId}');
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _siblings = [for (final s in sections ?? const []) ...s.lessons];
      _loading = false;
    });
  }

  bool get _fromApi => _detail != null;

  int get _apiIndex =>
      _siblings.indexWhere((l) => '${l.id}' == widget.lessonId);

  CatalogLesson? get _apiNext {
    final i = _apiIndex;
    return i >= 0 && i + 1 < _siblings.length ? _siblings[i + 1] : null;
  }

  String get _title => _detail?.title ?? _lessonTitle;

  String get _durationLabel => _detail?.durationLabel ?? '24:35';

  int get _lessonNumber => _fromApi ? (_apiIndex < 0 ? 1 : _apiIndex + 1) : 8;

  /// The lesson comes from the shared [MockRepository] when its id is known
  /// (ids `l1`, `l2`, ...). Any other id is the mockup's demo lesson, which
  /// continues with the first lesson that is not completed yet.
  bool get _isKnownLesson => MockRepository.lessonById(widget.lessonId) != null;

  LessonItem? get _nextLesson {
    if (_isKnownLesson) return MockRepository.nextLessonAfter(widget.lessonId);
    for (final section in MockRepository.curriculumFor('')) {
      for (final lesson in section.lessons) {
        if (lesson.state != LessonState.completed) return lesson;
      }
    }
    return null;
  }

  String get _nextTitle {
    if (_fromApi) return _apiNext?.title ?? 'จบหลักสูตร';
    if (!_isKnownLesson) return _nextLessonTitle;
    return _nextLesson?.title ?? 'จบหลักสูตร';
  }

  Future<void> _goNext() async {
    if (_fromApi) {
      await _goNextFromApi();
      return;
    }
    if (_isKnownLesson) MockRepository.completeLesson(widget.lessonId);
    final next = _nextLesson;
    if (next == null) {
      _showCourseCompleteDialog();
      return;
    }
    context.push(next.hasQuiz ? '/quiz/${next.id}' : '/player/${next.id}');
  }

  /// Marks this lesson completed on the server, then opens the next one.
  Future<void> _goNextFromApi() async {
    final detail = _detail!;
    final saved = await AppDependencies.catalogRepository.saveProgress(
      widget.lessonId,
      watchedSeconds: detail.durationSeconds,
      status: 'completed',
    );
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกความคืบหน้าไม่สำเร็จ')),
      );
    }
    final next = _apiNext;
    if (next == null) {
      _showCourseCompleteDialog();
      return;
    }
    context.push('/player/${next.id}');
  }

  void _showCourseCompleteDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เรียนครบทุกบทแล้ว!'),
        content: const Text('ยอดเยี่ยม คุณเรียนจบทุกบทในหลักสูตรนี้แล้ว'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/learn');
              }
            },
            child: const Text('กลับ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                      child: const Stack(
                        children: [
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
                          _title,
                          style:
                              AppTypography.base(14, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'บทเรียนที่ $_lessonNumber · $_durationLabel · ถัดไป: $_nextTitle',
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
                  label: 'บทเรียนถัดไป: $_nextTitle →',
                  onPressed: _goNext,
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
                    child: const Stack(
                      children: [
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
                      for (final (i, label) in const [
                        'Transcript',
                        'Notes',
                        'Discussion'
                      ].indexed) ...[
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
                          '▶ $_title',
                          style:
                              AppTypography.base(12.5, weight: FontWeight.w600),
                        ),
                        Text(
                          '$_durationLabel · กำลังเล่น',
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
                    onTap: _goNext,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nextTitle, style: AppTypography.base(12.5)),
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
