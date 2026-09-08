import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            _BrandMark(),
            SizedBox(width: 10),
            Text('AB LEARNING',
                style:
                    TextStyle(fontWeight: FontWeight.w800, letterSpacing: .2))
          ]),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search'),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notifications'),
            const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.secondary,
                    child: Text('A',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)))),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    if (wide) const _DesktopNavigation(),
                    _Hero(
                        onExplore: () => context.go('/courses'),
                        onTutor: () => context.go('/ai-tutor')),
                    const SizedBox(height: 28),
                    const _SectionHeading(
                        title: 'Continue learning',
                        subtitle: 'Pick up exactly where you left off'),
                    const SizedBox(height: 12),
                    if (wide)
                      Row(children: [
                        Expanded(
                            child: _LearningCard(
                                title: 'Go Backend Professional',
                                subtitle: 'Module 3 · REST API design',
                                progress: .68,
                                onTap: () => context.go('/course/c001'))),
                        const SizedBox(width: 14),
                        Expanded(
                            child: _LearningCard(
                                title: 'Flutter Professional',
                                subtitle: 'Module 2 · Navigation patterns',
                                progress: .42,
                                onTap: () => context.go('/course/c002'))),
                      ])
                    else ...[
                      _LearningCard(
                          title: 'Go Backend Professional',
                          subtitle: 'Module 3 · REST API design',
                          progress: .68,
                          onTap: () => context.go('/course/c001')),
                      const SizedBox(height: 12),
                      _LearningCard(
                          title: 'Flutter Professional',
                          subtitle: 'Module 2 · Navigation patterns',
                          progress: .42,
                          onTap: () => context.go('/course/c002')),
                    ],
                    const SizedBox(height: 28),
                    const _SectionHeading(
                        title: 'Build your career',
                        subtitle: 'Learn → practice → prove → get opportunity'),
                    const SizedBox(height: 12),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      _JourneyAction(
                          icon: Icons.auto_awesome_rounded,
                          title: 'AI Tutor',
                          caption: 'Ask anything',
                          color: const Color(0xFF7C3AED),
                          onTap: () => context.go('/ai-tutor')),
                      _JourneyAction(
                          icon: Icons.assessment_outlined,
                          title: 'Skill check',
                          caption: 'Find your gap',
                          color: const Color(0xFF0891B2),
                          onTap: () => context.go('/skill-assessment')),
                      _JourneyAction(
                          icon: Icons.route_rounded,
                          title: 'Career path',
                          caption: 'Plan next steps',
                          color: const Color(0xFF16A34A),
                          onTap: () => context.go('/career-path')),
                      _JourneyAction(
                          icon: Icons.work_outline_rounded,
                          title: 'Jobs',
                          caption: '92% top match',
                          color: const Color(0xFFEA580C),
                          onTap: () => context.go('/jobs')),
                    ]),
                  ]),
            ),
          );
        }),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(10)),
      child: const Text('AB',
          style: TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)));
}

// class _DesktopNavigation extends StatelessWidget {
//   const _DesktopNavigation();
//   @override
//   Widget build(BuildContext context) => const Padding(
//       padding: EdgeInsets.only(bottom: 22),
//       child: Wrap(spacing: 24, children: [
//         Text('Home',
//             style: TextStyle(
//                 color: AppColors.primary, fontWeight: FontWeight.bold)),
//         Text('Explore'),
//         Text('My learning'),
//         Text('Live'),
//         Text('Community'),
//         Text('Career')
//       ]));
// }

//เพิ่มปุ่มสำหรับการนำทางไปยังหน้าต่างๆ ของ FutureWorkspaceScreen 3 ปุ่ม
class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation();

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Wrap(spacing: 24, children: [
        _NavItem(label: 'Home', isActive: true, onTap: () => context.go('/home')),
        _NavItem(label: 'Explore', onTap: () => context.go('/courses')),
        _NavItem(label: 'My learning', onTap: () => context.go('/my-learning')),
        _NavItem(label: 'Live', onTap: () => context.go('/live')),
        _NavItem(label: 'Community', onTap: () => context.go('/community')),
        _NavItem(label: 'Career', onTap: () => context.go('/career-path')),
      ]));
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.onTap, this.isActive = false});
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label,
            style: TextStyle(
                color: isActive ? AppColors.primary : null,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ));
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onExplore, required this.onTutor});
  final VoidCallback onExplore;
  final VoidCallback onTutor;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF312E81),
                  AppColors.primary,
                  AppColors.secondary
                ]),
            borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('สวัสดี คุณอนันต์ 👋',
              style: TextStyle(
                  color: Color(0xFFC7D2FE), fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          const Text('What do you want to\nachieve today?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.08,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text('Your next skill is one focused session away.',
              style: TextStyle(color: Color(0xFFE0E7FF))),
          const SizedBox(height: 22),
          Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary),
                onPressed: onExplore,
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore courses')),
            OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFBDB7FF))),
                onPressed: onTutor,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Ask AI Tutor')),
          ]),
        ]),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary))
      ]);
}

class _JourneyAction extends StatelessWidget {
  const _JourneyAction(
      {required this.icon,
      required this.title,
      required this.caption,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String title;
  final String caption;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 166,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                                color: color.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(icon, color: color)),
                        const SizedBox(height: 16),
                        Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        Text(caption,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12))
                      ])))));
}

class _LearningCard extends StatelessWidget {
  const _LearningCard(
      {required this.title,
      required this.subtitle,
      required this.progress,
      required this.onTap});
  final String title;
  final String subtitle;
  final double progress;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.play_circle_fill_rounded,
                        color: AppColors.primary)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 12),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 7,
                              backgroundColor: const Color(0xFFE2E8F0),
                              color: AppColors.primary))
                    ])),
                const SizedBox(width: 12),
                Text('${(progress * 100).round()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.primary))
              ]))));
}
