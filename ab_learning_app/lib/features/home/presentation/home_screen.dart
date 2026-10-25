import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final continueLearning =
        MockRepository.enrolledCourses.where((c) => c.progress < 1.0).toList();
    final recommended = MockRepository.courses
        .where((c) => c.completedLessons == 0 && c.progress == 0)
        .toList();

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('สวัสดี, คุณอนันต์ 👋'),
              titleTextStyle: AppTypography.body
                  .copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
              actions: [
                IconButton(
                  tooltip: 'ค้นหาคอร์ส',
                  onPressed: () => context.go('/explore'),
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  tooltip: 'การแจ้งเตือน',
                  onPressed: () => _showNotifications(context),
                  icon: const Icon(Icons.notifications_none),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Center(child: _CoinBalance()),
                ),
                PopupMenuButton<String>(
                  tooltip: 'บัญชีผู้เรียน',
                  onSelected: (value) {
                    if (value == 'learning') context.go('/my-learning');
                    if (value == 'role') showRoleSwitcherSheet(context);
                    if (value == 'profile') context.go('/profile');
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'profile', child: Text('โปรไฟล์')),
                    PopupMenuItem(
                        value: 'learning', child: Text('การเรียนของฉัน')),
                    PopupMenuItem(value: 'role', child: Text('เปลี่ยนบทบาท')),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary,
                      child: Text('A',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: ListView(
            padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16,
                isDesktop ? 24 : 16, isDesktop ? 32 : 16, 24),
            children: [
              if (isDesktop) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('สวัสดี, คุณอนันต์ 👋',
                            style: AppTypography.h1),
                        Text(
                          'มาต่อการเรียนรู้ของวันนี้กันเถอะ',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'ค้นหาคอร์ส',
                          onPressed: () => context.go('/explore'),
                          icon: const Icon(Icons.search),
                        ),
                        IconButton(
                          tooltip: 'การแจ้งเตือน',
                          onPressed: () => _showNotifications(context),
                          icon: const Icon(Icons.notifications_none),
                        ),
                        const SizedBox(width: 8),
                        const _CoinBalance(),
                        const SizedBox(width: 14),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child:
                              Text('A', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],
              _HeroPromptCard(isDesktop: isDesktop),
              if (continueLearning.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'เรียนต่อ',
                  onSeeAll: () => context.push('/my-learning'),
                ),
                const SizedBox(height: 12),
                _CourseCollection(
                  courses: continueLearning,
                  isDesktop: isDesktop,
                  showProgress: true,
                ),
              ],
              const SizedBox(height: 26),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                              title: 'แนะนำสำหรับคุณ',
                              onSeeAll: () => context.go('/explore')),
                          const SizedBox(height: 12),
                          _CourseCollection(
                              courses: recommended, isDesktop: true),
                          const SizedBox(height: 24),
                          const Text('Live กำลังจะเริ่ม',
                              style: AppTypography.h2),
                          const SizedBox(height: 12),
                          const _UpcomingLiveCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _SectionHeader(
                    title: 'แนะนำสำหรับคุณ',
                    onSeeAll: () => context.go('/explore')),
                const SizedBox(height: 12),
                _CourseCollection(courses: recommended, isDesktop: false),
                const SizedBox(height: 24),
                const Text('Live กำลังจะเริ่ม', style: AppTypography.h2),
                const SizedBox(height: 12),
                const _UpcomingLiveCard(),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_none),
        title: const Text('ยังไม่มีการแจ้งเตือน'),
        content: const Text('เมื่อมีข่าวสารเกี่ยวกับคอร์สของคุณ จะแสดงที่นี่'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด')),
        ],
      ),
    );
  }
}

class _CoinBalance extends StatelessWidget {
  const _CoinBalance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: const Text(
        '🪙 2,450',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF92400E)),
      ),
    );
  }
}

class _HeroPromptCard extends StatelessWidget {
  const _HeroPromptCard({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: isDesktop ? 2 : 1,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: () =>
                  context.push('/tutor', extra: 'your learning journey'),
              child: Ink(
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('วันนี้อยากพัฒนาอะไร?',
                        style: AppTypography.h2.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      isDesktop
                          ? 'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณแบบเฉพาะบุคคล'
                          : 'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณ',
                      style:
                          AppTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context.push('/tutor',
                          extra: 'your learning journey'),
                      icon: const Icon(Icons.auto_awesome, size: 17),
                      label: const Text('ถาม AI Tutor'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(width: 18),
          const Expanded(child: _CareerProgressCard()),
        ],
      ],
    );
  }
}

class _CareerProgressCard extends StatelessWidget {
  const _CareerProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Career Path Progress',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('78%', style: AppTypography.h1),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: 0.78, minHeight: 6),
        ],
      ),
    );
  }
}

class _CourseCollection extends StatelessWidget {
  const _CourseCollection(
      {required this.courses,
      required this.isDesktop,
      this.showProgress = false});

  final List<Course> courses;
  final bool isDesktop;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: courses
            .map((course) =>
                _HomeCourseCard(course: course, showProgress: showProgress))
            .toList(),
      );
    }
    return SizedBox(
      height: showProgress ? 206 : 198,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _HomeCourseCard(course: courses[index], showProgress: showProgress),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h2)),
        IconButton(
          onPressed: onSeeAll,
          tooltip: 'ดูทั้งหมด',
          icon: const Icon(Icons.arrow_forward, size: 18),
        ),
      ],
    );
  }
}

class _HomeCourseCard extends StatelessWidget {
  final Course course;
  final bool showProgress;

  const _HomeCourseCard({required this.course, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${course.coverColorHex}', radix: 16));
    final showCourseProgress = showProgress;

    return SizedBox(
      width: 228,
      height: showProgress ? 206 : 198,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.push(
          showCourseProgress
              ? '/course/${course.id}/curriculum'
              : '/course/${course.id}',
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 92,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, Color.lerp(color, Colors.black, 0.24)!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  showCourseProgress
                      ? Icons.play_circle_fill
                      : Icons.school_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h2.copyWith(fontSize: 13),
                      ),
                      const Spacer(),
                      if (showCourseProgress) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.badge),
                          child: LinearProgressIndicator(
                            value: course.progress,
                            minHeight: 6,
                            backgroundColor: AppColors.cardBorder,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${(course.progress * 100).round()}% เสร็จแล้ว · เรียนต่อ',
                          style: AppTypography.micro
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: AppColors.warning, size: 14),
                                const SizedBox(width: 4),
                                Text(course.rating.toStringAsFixed(1),
                                    style: AppTypography.caption),
                              ],
                            ),
                            Text(course.priceLabel,
                                style: AppTypography.caption
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingLiveCard extends StatefulWidget {
  const _UpcomingLiveCard();

  @override
  State<_UpcomingLiveCard> createState() => _UpcomingLiveCardState();
}

class _UpcomingLiveCardState extends State<_UpcomingLiveCard> {
  bool _reminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => setState(() => _reminderEnabled = !_reminderEnabled),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(Icons.podcasts, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI for Business · Live Q&A', style: AppTypography.h2),
                    SizedBox(height: 4),
                    Text('วันนี้ 19:00 น. · ถามตอบกับผู้สอน',
                        style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _reminderEnabled
                      ? AppColors.pillSuccessBg
                      : const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Text(
                  _reminderEnabled ? 'เตือนแล้ว' : 'อีก 2 ชม.',
                  style: TextStyle(
                    color: _reminderEnabled
                        ? AppColors.success
                        : const Color(0xFF0E7490),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
