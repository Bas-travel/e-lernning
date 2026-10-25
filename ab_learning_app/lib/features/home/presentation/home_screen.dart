import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// <<<<<<< design/tokens-update
// import '../../../core/theme/colors.dart';
// =======
// import '../../../core/di/app_dependencies.dart';
// import '../../../core/router/nav_targets.dart';
// import '../../../core/theme/colors.dart';
// import '../../../core/theme/radius.dart';
// import '../../../core/theme/typography.dart';
// import '../../../core/widgets/app_avatar.dart';
// import '../../../core/widgets/app_bottom_nav.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/app_card.dart';
// import '../../../core/widgets/app_progress_bar.dart';
// import '../../../core/widgets/app_sidebar.dart';
// import '../../../core/widgets/course_card.dart';
// import '../../../core/widgets/responsive.dart';
// import '../../../core/widgets/status_pill.dart';
// import 'home_sample_data.dart';
// >>>>>>> main

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
// <<<<<<< design/tokens-update
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: const Row(children: [
//             _BrandMark(),
//             SizedBox(width: 10),
//             Text('AB LEARNING',
//                 style:
//                     TextStyle(fontWeight: FontWeight.w800, letterSpacing: .2))
//           ]),
//           actions: [
//             IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.search_rounded),
//                 tooltip: 'Search'),
//             IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.notifications_none_rounded),
//                 tooltip: 'Notifications'),
//             const Padding(
//                 padding: EdgeInsets.only(right: 16),
//                 child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: AppColors.secondary,
//                     child: Text('A',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold)))),
// =======
//   Widget build(BuildContext context) {
//     final user = AppDependencies.authRepository.currentUser;
//     final name = user?.displayName ?? HomeSampleData.userName;
//     final initial = user?.initial ?? HomeSampleData.userInitial;
//     return ResponsiveBuilder(
//       mobile: (_) => _HomeMobile(name: name, initial: initial),
//       desktop: (_) => _HomeDesktop(name: name, initial: initial),
//     );
//   }
// }

// // ---------------------------------------------------------------- mobile

// class _HomeMobile extends StatelessWidget {
//   const _HomeMobile({required this.name, required this.initial});

//   final String name;
//   final String initial;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(bottom: BorderSide(color: AppColors.border)),
//             ),
//             child: SafeArea(
//               bottom: false,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         'สวัสดี, $name 👋',
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTypography.base(14, weight: FontWeight.w600),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     _UserActions(gap: 14, initial: initial),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: CenteredContent(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: _HeroCard(
//                         titleSize: 14,
//                         subtitleSize: 11.5,
//                         subtitle: 'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณ',
//                         buttonPadding:
//                             const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                         buttonFontSize: 12,
//                         titleGap: 4,
//                         subtitleGap: 10,
//                       ),
//                     ),
//                     const _SectionTitle('เรียนต่อ', horizontalPadding: 16),
//                     const _ContinueRow(),
//                     const _SectionTitle('แนะนำสำหรับคุณ', horizontalPadding: 16),
//                     const _RecommendedRow(),
//                     const _SectionTitle(
//                       'Live กำลังจะเริ่ม',
//                       horizontalPadding: 16,
//                     ),
//                     const _LiveRow(),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: AppBottomNav(
//         currentIndex: 0,
//         // Learn / Community / Profile tabs have no screens yet (ignored).
//         onTap: (index) => NavTargets.onTab(context, index),
//       ),
//     );
//   }
// }

// class _ContinueRow extends StatelessWidget {
//   const _ContinueRow();

//   @override
//   Widget build(BuildContext context) {
//     return _HScroll(
//       children: [
//         CourseCard(
//           width: 230,
//           title: HomeSampleData.continueTitle,
//           extra: const AppProgressBar(value: HomeSampleData.continueProgress),
//           meta: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Flexible(
//                 child: Text('68% เสร็จแล้ว', overflow: TextOverflow.ellipsis),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'เรียนต่อ',
//                 style: AppTypography.base(
//                   11,
//                   weight: FontWeight.w600,
//                   color: AppColors.primary,
//                   height: 1.2,
//                 ),
//               ),
//             ],
//           ),
//           onTap: () =>
//               context.push('/player/${HomeSampleData.continueLessonId}'),
//         ),
//       ],
//     );
//   }
// }

// class _RecommendedRow extends StatelessWidget {
//   const _RecommendedRow();

//   @override
//   Widget build(BuildContext context) {
//     // Mockup (mobile) shows the first two recommended courses.
//     return _HScroll(
//       children: [
//         for (final course in HomeSampleData.recommended.take(2))
//           _recommendedCard(context, course, width: 180),
//       ],
//     );
//   }
// }

// class _LiveRow extends StatelessWidget {
//   const _LiveRow();

//   @override
//   Widget build(BuildContext context) {
//     return _HScroll(children: [_liveCard(width: 180)]);
//   }
// }

// // --------------------------------------------------------------- desktop

// class _HomeDesktop extends StatelessWidget {
//   const _HomeDesktop({required this.name, required this.initial});

//   final String name;
//   final String initial;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           AppSidebar(
//             activeKey: 'home',
//             onSelect: (key) => NavTargets.onSidebar(context, key),
//           ),
//           Expanded(
//             child: ColoredBox(
//               color: AppColors.background,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'สวัสดี, $name 👋',
//                               style: AppTypography.base(
//                                 19,
//                                 weight: FontWeight.w700,
//                               ),
//                             ),
//                             Text(
//                               'มาต่อการเรียนรู้ของวันนี้กันเถอะ',
//                               style: AppTypography.base(
//                                 12.5,
//                                 color: AppColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         _UserActions(gap: 16, initial: initial),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     IntrinsicHeight(
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: _HeroCard(
//                               titleSize: 16,
//                               subtitleSize: 12.5,
//                               subtitle:
//                                   'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณแบบเฉพาะบุคคล',
//                               buttonPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 9,
//                               ),
//                               buttonFontSize: 12.5,
//                               titleGap: 6,
//                               subtitleGap: 14,
//                             ),
//                           ),
//                           const SizedBox(width: 18),
//                           Expanded(
//                             child: AppCard(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Career Path Progress',
//                                     style: AppTypography.base(
//                                       12,
//                                       color: AppColors.textSecondary,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     '${(HomeSampleData.careerProgress * 100).round()}%',
//                                     style: AppTypography.base(
//                                       20,
//                                       weight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   const AppProgressBar(
//                                     value: HomeSampleData.careerProgress,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 22),
//                     const _SectionTitle('แนะนำสำหรับคุณ'),
//                     const SizedBox(height: 12),
//                     CardGrid(
//                       columns: 3,
//                       children: [
//                         for (final course in HomeSampleData.recommended)
//                           _recommendedCard(context, course),
//                       ],
//                     ),
//                     const SizedBox(height: 22),
//                     const _SectionTitle('Live กำลังจะเริ่ม'),
//                     const SizedBox(height: 12),
//                     CardGrid(columns: 3, children: [_liveCard()]),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------- shared

// Widget _recommendedCard(
//   BuildContext context,
//   HomeCourse course, {
//   double? width,
// }) {
//   return CourseCard(
//     width: width,
//     title: course.title,
//     gradient: course.gradient,
//     meta: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [Text(course.rating), Text(course.price)],
//     ),
//     onTap: () => context.push('/course/${course.id}'),
//   );
// }

// Widget _liveCard({double? width}) {
//   return CourseCard(
//     width: width,
//     title: HomeSampleData.liveTitle,
//     gradient: AppGradients.live,
//     meta: const Row(
//       children: [
//         StatusPill(
//           label: HomeSampleData.liveStartsIn,
//           variant: StatusPillVariant.live,
//         ),
//       ],
//     ),
//   );
// }

// class _SectionTitle extends StatelessWidget {
//   const _SectionTitle(this.text, {this.horizontalPadding = 0});

//   final String text;
//   final double horizontalPadding;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         horizontalPadding,
//         // Mobile mockup: margin 18px 0 10px. Desktop spacing is handled by the
//         // caller (collapsed margins), so no extra top space is added there.
//         horizontalPadding > 0 ? 18 : 0,
//         horizontalPadding,
//         horizontalPadding > 0 ? 10 : 0,
//       ),
//       child: Text(
//         text,
//         style: AppTypography.base(14, weight: FontWeight.w600),
//       ),
//     );
//   }
// }

// class _HScroll extends StatelessWidget {
//   const _HScroll({required this.children});

//   final List<Widget> children;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             for (var i = 0; i < children.length; i++) ...[
//               if (i > 0) const SizedBox(width: 12),
//               children[i],
//             ],
// >>>>>>> main
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.titleSize,
    required this.subtitleSize,
    required this.subtitle,
    required this.buttonPadding,
    required this.buttonFontSize,
    required this.titleGap,
    required this.subtitleGap,
  });

  final double titleSize;
  final double subtitleSize;
  final String subtitle;
  final EdgeInsets buttonPadding;
  final double buttonFontSize;
  final double titleGap;
  final double subtitleGap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppGradients.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'วันนี้อยากพัฒนาอะไร?',
            style: AppTypography.base(
              titleSize,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: titleGap),
          Text(
            subtitle,
            style: AppTypography.base(
              subtitleSize,
              color: AppColors.whiteA85,
            ),
          ),
          SizedBox(height: subtitleGap),
          AppButton.inverse(
            label: 'ถาม AI Tutor →',
            onPressed: () => context.push('/tutor'),
            fontSize: buttonFontSize,
            padding: buttonPadding,
          ),
        ],
      ),
    );
  }
}

class _UserActions extends StatelessWidget {
  const _UserActions({required this.gap, required this.initial});

  final double gap;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
        SizedBox(width: gap),
        const Icon(
          Icons.notifications_none,
          size: 18,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: gap),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.coinBg,
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Text(
            '🪙 ${HomeSampleData.coins}',
            style: AppTypography.base(
              11,
              weight: FontWeight.w600,
              color: AppColors.coinFg,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: gap),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/profile'),
          child: AppAvatar(initial: initial),
        ),
      ],
    );
  }
}
