import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/course_card.dart';
import '../../../../core/widgets/live_card.dart';
import '../../models/home_feed.dart';

/// Desktop layout for screen 08, per `01-screens-spec.md`:
/// sidebar (240px) + main content (Hero, Continue, Recommended grid 3-up,
/// Live 3-up) + right rail (Career Path progress).
class DesktopHomeLayout extends StatelessWidget {
  const DesktopHomeLayout({required this.feed, super.key});

  final HomeFeed feed;

  static const List<String> _navItems = <String>[
    'Home', 'Explore', 'My Learning', 'Live', 'Community',
    'AI Tutor', 'Career', 'Portfolio', 'Jobs', 'Wallet', 'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _Sidebar(activeItem: 'Home', items: _navItems),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TopRow(greetingName: feed.greetingName),
                  const SizedBox(height: 22),
                  _HeroRow(careerProgressPct: feed.careerPathProgressPct),
                  if (feed.recommended.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 24),
                    const Text('แนะนำสำหรับคุณ', style: AppTypography.h2),
                    const SizedBox(height: 12),
                    _CourseGrid(courses: feed.recommended),
                  ],
                  if (feed.live.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 24),
                    const Text('Live กำลังจะเริ่ม', style: AppTypography.h2),
                    const SizedBox(height: 12),
                    _LiveGrid(live: feed.live),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.activeItem, required this.items});

  final String activeItem;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('AB LEARNING',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const SizedBox(height: 10),
          for (final String item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Material(
                color: item == activeItem ? const Color(0xFFEEF2FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: item == activeItem ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: item == activeItem ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.greetingName});

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('สวัสดี, คุณ$greetingName 👋', style: AppTypography.h1),
            const Text('มาต่อการเรียนรู้ของวันนี้กันเถอะ', style: AppTypography.caption),
          ],
        ),
        Row(
          children: <Widget>[
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            const Icon(Icons.notifications_none, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
              child: const Text('🪙 2,450',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
            ),
            const SizedBox(width: 16),
            const CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: Text('A', style: TextStyle(color: Colors.white))),
          ],
        ),
      ],
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.careerProgressPct});

  final double careerProgressPct;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('วันนี้อยากพัฒนาอะไร?',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text(
                  'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณแบบเฉพาะบุคคล',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('ถาม AI Tutor →'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Career Path Progress', style: AppTypography.caption),
                const SizedBox(height: 6),
                Text('${careerProgressPct.toStringAsFixed(0)}%', style: AppTypography.h1),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                  child: LinearProgressIndicator(
                    value: careerProgressPct / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseGrid extends StatelessWidget {
  const _CourseGrid({required this.courses});

  final List<CourseSummary> courses;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: courses
          .map(
            (CourseSummary course) => CourseCard(
              title: course.title,
              width: 250,
              ratingAvg: course.ratingAvg,
              price: course.price,
              gradient: course.thumbnailGradient,
              onTap: () {},
            ),
          )
          .toList(),
    );
  }
}

class _LiveGrid extends StatelessWidget {
  const _LiveGrid({required this.live});

  final List<LiveSummary> live;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: live
          .map(
            (LiveSummary l) => LiveCard(
              title: l.title,
              instructorName: l.instructorName,
              width: 250,
              isLiveNow: l.isLiveNow,
              startsInLabel: l.isLiveNow ? null : l.startsInLabel(),
            ),
          )
          .toList(),
    );
  }
}
