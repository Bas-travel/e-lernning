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

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  void _showPreviewStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('วิดีโอตัวอย่างของบทเรียนนี้ยังไม่พร้อมใช้งาน')),
    );
  }

  void _showCourseCompleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เรียนครบทุกบทแล้ว!'),
        content: const Text('ยอดเยี่ยม คุณเรียนจบทุกบทในหลักสูตรนี้แล้ว'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close the dialog
              context.pop(); // back to curriculum
            },
            child: const Text('กลับไปยังหลักสูตร'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = MockRepository.lessonById(widget.lessonId);
    final title = lesson?.title ?? 'บทเรียน';
    final isLast = MockRepository.isLastLesson(widget.lessonId);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black87,
              child: Center(
                child: IconButton(
                  tooltip: 'เล่นตัวอย่างบทเรียน',
                  onPressed: _showPreviewStatus,
                  icon: const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 64),
                ),
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
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
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
              Tab(text: 'เอกสาร'),
              Tab(text: 'โน้ต'),
              Tab(text: 'พูดคุย'),
              Tab(text: 'Ask AI ✨'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _EmptyTabContent(
                  icon: Icons.attach_file,
                  message: 'บทเรียนนี้ยังไม่มีเอกสารประกอบ',
                ),
                const _EmptyTabContent(
                  icon: Icons.edit_note,
                  message: 'โน้ตของบทเรียนนี้จะแสดงที่นี่',
                ),
                const _EmptyTabContent(
                  icon: Icons.forum_outlined,
                  message: 'เริ่มพูดคุยเกี่ยวกับบทเรียนนี้ได้ที่นี่',
                ),
                _AskTutorTab(
                  onTap: () => context.push('/tutor', extra: title),
                ),
              ],
            ),
          ),
        ],
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              onPressed: _completeAndAdvance,
              icon: Icon(isLast ? Icons.flag : Icons.arrow_forward,
                  color: Colors.white),
              label: Text(
                isLast ? 'จบบทเรียน' : 'บทเรียนถัดไป',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AskTutorTab extends StatelessWidget {
  const _AskTutorTab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 36, color: AppColors.primary),
            const SizedBox(height: 10),
            const Text('ถาม AI เกี่ยวกับบทเรียนนี้', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(
              'รับคำอธิบายและตัวอย่างที่อ้างอิงจากบทเรียนที่กำลังเรียน',
              textAlign: TextAlign.center,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('เปิด AI Tutor'),
            ),
          ],
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
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
