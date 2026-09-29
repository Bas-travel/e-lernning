import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';

/// Screen 13 — Video Player / Learning. Plays a single lesson, tracks
/// completion, and routes to the next lesson (or its quiz) when done.
class VideoPlayerScreen extends StatefulWidget {
  final String lessonId;

  const VideoPlayerScreen({super.key, required this.lessonId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _completeAndAdvance() {
    MockRepository.completeLesson(widget.lessonId);
    final next = MockRepository.nextLessonAfter(widget.lessonId);

    if (next == null) {
      _showCourseCompleteDialog();
      return;
    }
    if (next.hasQuiz) {
      context.push('/quiz/${next.id}');
    } else {
      context.push('/player/${next.id}');
    }
  }

  void _showCourseCompleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('🎉 All lessons complete!'),
        content: const Text('Nice work — you\'ve finished every lesson in this section.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close the dialog
              context.pop(); // back to curriculum
            },
            child: const Text('Back to Curriculum'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = MockRepository.lessonById(widget.lessonId);
    final title = lesson?.title ?? 'Lesson';
    final isLast = MockRepository.isLastLesson(widget.lessonId);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h1.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  lesson?.duration ?? '',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Resources'),
              Tab(text: 'Notes'),
              Tab(text: 'Discussion'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _EmptyTabContent(
                  icon: Icons.attach_file,
                  message: 'No downloadable resources for this lesson yet.',
                ),
                _EmptyTabContent(
                  icon: Icons.edit_note,
                  message: 'Your notes for this lesson will show up here.',
                ),
                _EmptyTabContent(
                  icon: Icons.forum_outlined,
                  message: 'Be the first to start a discussion on this lesson.',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tutor'),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask AI'),
        backgroundColor: AppColors.secondary,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimaryBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              onPressed: _completeAndAdvance,
              icon: Icon(isLast ? Icons.flag : Icons.arrow_forward, color: Colors.white),
              label: Text(
                isLast ? 'Finish Course' : 'Next Lesson',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTabContent extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyTabContent({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
