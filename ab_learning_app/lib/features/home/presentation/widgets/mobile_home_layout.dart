import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/course_card.dart';
import '../../../../core/widgets/live_card.dart';
import '../../models/home_feed.dart';

/// Mobile layout for screen 08, per `01-screens-spec.md`:
/// top bar → hero AI prompt card → horizontal "Continue Learning" →
/// horizontal Recommended → horizontal Popular Live.
class MobileHomeLayout extends StatelessWidget {
  const MobileHomeLayout({required this.feed, super.key});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: _TopBar(greetingName: feed.greetingName)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _HeroPromptCard(),
          ),
        ),
        if (feed.continueLearning.isNotEmpty) ...<Widget>[
          const _SectionHeader(title: 'เรียนต่อ'),
          _HorizontalCourseList(courses: feed.continueLearning, cardWidth: 230),
        ],
        if (feed.recommended.isNotEmpty) ...<Widget>[
          const _SectionHeader(title: 'แนะนำสำหรับคุณ'),
          _HorizontalCourseList(courses: feed.recommended, cardWidth: 170),
        ],
        if (feed.live.isNotEmpty) ...<Widget>[
          const _SectionHeader(title: 'Live กำลังจะเริ่ม'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: feed.live.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, int i) {
                  final LiveSummary live = feed.live[i];
                  return LiveCard(
                    title: live.title,
                    instructorName: live.instructorName,
                    width: 230,
                    isLiveNow: live.isLiveNow,
                    startsInLabel: live.isLiveNow ? null : live.startsInLabel(),
                  );
                },
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.greetingName});

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('สวัสดี, คุณ$greetingName 👋',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          Row(
            children: <Widget>[
              const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              const Icon(Icons.notifications_none, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: const Text('🪙 2,450',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
              ),
              const SizedBox(width: 14),
              const CircleAvatar(radius: 15, backgroundColor: AppColors.primary, child: Text('A', style: TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPromptCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('วันนี้อยากพัฒนาอะไร?',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('ถาม AI Tutor เพื่อวางแผนการเรียนของคุณ',
              style: TextStyle(color: Colors.white70, fontSize: 11.5)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('ถาม AI Tutor →', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Text(title, style: AppTypography.h2.copyWith(fontSize: 14)),
      ),
    );
  }
}

class _HorizontalCourseList extends StatelessWidget {
  const _HorizontalCourseList({required this.courses, required this.cardWidth});

  final List<CourseSummary> courses;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: courses.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, int i) {
            final CourseSummary course = courses[i];
            return CourseCard(
              title: course.title,
              width: cardWidth,
              ratingAvg: course.ratingAvg,
              price: course.price,
              progressPct: course.progressPct,
              gradient: course.thumbnailGradient,
              onTap: () {
                // TODO: context.push('/course/${course.id}') once screen 11 exists.
              },
            );
          },
        ),
      ),
    );
  }
}
