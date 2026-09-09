// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../../../core/theme/colors.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
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
//           ],
//         ),
//         body: LayoutBuilder(builder: (context, constraints) {
//           final wide = constraints.maxWidth >= 900;
//           return Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1180),
//               child: ListView(
//                   padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
//                   children: [
//                     if (wide) const _DesktopNavigation(),
//                     _Hero(
//                         onExplore: () => context.go('/courses'),
//                         onTutor: () => context.go('/ai-tutor')),
//                     const SizedBox(height: 28),
//                     const _SectionHeading(
//                         title: 'Continue learning',
//                         subtitle: 'Pick up exactly where you left off'),
//                     const SizedBox(height: 12),
//                     if (wide)
//                       Row(children: [
//                         Expanded(
//                             child: _LearningCard(
//                                 title: 'Go Backend Professional',
//                                 subtitle: 'Module 3 · REST API design',
//                                 progress: .68,
//                                 onTap: () => context.go('/course/c001'))),
//                         const SizedBox(width: 14),
//                         Expanded(
//                             child: _LearningCard(
//                                 title: 'Flutter Professional',
//                                 subtitle: 'Module 2 · Navigation patterns',
//                                 progress: .42,
//                                 onTap: () => context.go('/course/c002'))),
//                       ])
//                     else ...[
//                       _LearningCard(
//                           title: 'Go Backend Professional',
//                           subtitle: 'Module 3 · REST API design',
//                           progress: .68,
//                           onTap: () => context.go('/course/c001')),
//                       const SizedBox(height: 12),
//                       _LearningCard(
//                           title: 'Flutter Professional',
//                           subtitle: 'Module 2 · Navigation patterns',
//                           progress: .42,
//                           onTap: () => context.go('/course/c002')),
//                     ],
//                     const SizedBox(height: 28),
//                     const _SectionHeading(
//                         title: 'Build your career',
//                         subtitle: 'Learn → practice → prove → get opportunity'),
//                     const SizedBox(height: 12),
//                     Wrap(spacing: 12, runSpacing: 12, children: [
//                       _JourneyAction(
//                           icon: Icons.auto_awesome_rounded,
//                           title: 'AI Tutor',
//                           caption: 'Ask anything',
//                           color: const Color(0xFF7C3AED),
//                           onTap: () => context.go('/ai-tutor')),
//                       _JourneyAction(
//                           icon: Icons.assessment_outlined,
//                           title: 'Skill check',
//                           caption: 'Find your gap',
//                           color: const Color(0xFF0891B2),
//                           onTap: () => context.go('/skill-assessment')),
//                       _JourneyAction(
//                           icon: Icons.route_rounded,
//                           title: 'Career path',
//                           caption: 'Plan next steps',
//                           color: const Color(0xFF16A34A),
//                           onTap: () => context.go('/career-path')),
//                       _JourneyAction(
//                           icon: Icons.work_outline_rounded,
//                           title: 'Jobs',
//                           caption: '92% top match',
//                           color: const Color(0xFFEA580C),
//                           onTap: () => context.go('/jobs')),
//                     ]),
//                   ]),
//             ),
//           );
//         }),
//       );
// }

// class _BrandMark extends StatelessWidget {
//   const _BrandMark();
//   @override
//   Widget build(BuildContext context) => Container(
//       width: 32,
//       height: 32,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//           gradient: const LinearGradient(
//               colors: [AppColors.primary, AppColors.secondary]),
//           borderRadius: BorderRadius.circular(10)),
//       child: const Text('AB',
//           style: TextStyle(
//               color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)));
// }

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

// class _Hero extends StatelessWidget {
//   const _Hero({required this.onExplore, required this.onTutor});
//   final VoidCallback onExplore;
//   final VoidCallback onTutor;
//   @override
//   Widget build(BuildContext context) => Container(
//         padding: const EdgeInsets.all(28),
//         decoration: BoxDecoration(
//             gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF312E81),
//                   AppColors.primary,
//                   AppColors.secondary
//                 ]),
//             borderRadius: BorderRadius.circular(24)),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('สวัสดี คุณอนันต์ 👋',
//               style: TextStyle(
//                   color: Color(0xFFC7D2FE), fontWeight: FontWeight.w600)),
//           const SizedBox(height: 10),
//           const Text('What do you want to\nachieve today?',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 30,
//                   height: 1.08,
//                   fontWeight: FontWeight.w800)),
//           const SizedBox(height: 12),
//           const Text('Your next skill is one focused session away.',
//               style: TextStyle(color: Color(0xFFE0E7FF))),
//           const SizedBox(height: 22),
//           Wrap(spacing: 10, runSpacing: 10, children: [
//             FilledButton.icon(
//                 style: FilledButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: AppColors.primary),
//                 onPressed: onExplore,
//                 icon: const Icon(Icons.explore_outlined),
//                 label: const Text('Explore courses')),
//             OutlinedButton.icon(
//                 style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     side: const BorderSide(color: Color(0xFFBDB7FF))),
//                 onPressed: onTutor,
//                 icon: const Icon(Icons.auto_awesome_outlined),
//                 label: const Text('Ask AI Tutor')),
//           ]),
//         ]),
//       );
// }

// class _SectionHeading extends StatelessWidget {
//   const _SectionHeading({required this.title, required this.subtitle});
//   final String title;
//   final String subtitle;
//   @override
//   Widget build(BuildContext context) =>
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(title,
//             style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
//         const SizedBox(height: 3),
//         Text(subtitle, style: const TextStyle(color: AppColors.textSecondary))
//       ]);
// }

// class _JourneyAction extends StatelessWidget {
//   const _JourneyAction(
//       {required this.icon,
//       required this.title,
//       required this.caption,
//       required this.color,
//       required this.onTap});
//   final IconData icon;
//   final String title;
//   final String caption;
//   final Color color;
//   final VoidCallback onTap;
//   @override
//   Widget build(BuildContext context) => SizedBox(
//       width: 166,
//       child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Card(
//               child: Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                             padding: const EdgeInsets.all(9),
//                             decoration: BoxDecoration(
//                                 color: color.withValues(alpha: .12),
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Icon(icon, color: color)),
//                         const SizedBox(height: 16),
//                         Text(title,
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.w800)),
//                         Text(caption,
//                             style: const TextStyle(
//                                 color: AppColors.textSecondary, fontSize: 12))
//                       ])))));
// }

// class _LearningCard extends StatelessWidget {
//   const _LearningCard(
//       {required this.title,
//       required this.subtitle,
//       required this.progress,
//       required this.onTap});
//   final String title;
//   final String subtitle;
//   final double progress;
//   final VoidCallback onTap;
//   @override
//   Widget build(BuildContext context) => InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Card(
//           child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(children: [
//                 Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                         color: AppColors.primary.withValues(alpha: .1),
//                         borderRadius: BorderRadius.circular(14)),
//                     child: const Icon(Icons.play_circle_fill_rounded,
//                         color: AppColors.primary)),
//                 const SizedBox(width: 14),
//                 Expanded(
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                       Text(title,
//                           style: const TextStyle(fontWeight: FontWeight.w800)),
//                       const SizedBox(height: 3),
//                       Text(subtitle,
//                           style: const TextStyle(
//                               color: AppColors.textSecondary, fontSize: 13)),
//                       const SizedBox(height: 12),
//                       ClipRRect(
//                           borderRadius: BorderRadius.circular(99),
//                           child: LinearProgressIndicator(
//                               value: progress,
//                               minHeight: 7,
//                               backgroundColor: const Color(0xFFE2E8F0),
//                               color: AppColors.primary))
//                     ])),
//                 const SizedBox(width: 12),
//                 Text('${(progress * 100).round()}%',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w800, color: AppColors.primary))
//               ]))));
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: wide ? const _DesktopHome() : const _MobileHome(),
            bottomNavigationBar: wide ? null : const _MobileBottomNav(),
          );
        },
      );
}

// ---------------------------------------------------------------------------
// DESKTOP LAYOUT — sidebar + content, matches 02-hifi-mockups.html `home.d`
// ---------------------------------------------------------------------------

class _DesktopHome extends StatelessWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Sidebar(active: 'home'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopRow(),
                  const SizedBox(height: 22),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.stretch,
                  //   children: [
                  //     Expanded(
                  //       flex: 2,
                  //       child: _HeroCard(
                  //         onTutor: () => context.go('/ai-tutor'),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 18),
                  //     const Expanded(flex: 1, child: _CareerProgressCard()),
                  //   ],
                  // ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _HeroCard(
                              onTutor: () => context.go('/ai-tutor'),
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Expanded(flex: 1, child: _CareerProgressCard()),
                        ],
                      ),
                    ),

                  const SizedBox(height: 22),
                  const _SectionHeading(title: 'แนะนำสำหรับคุณ'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.35,
                    children: [
                      _CourseCard(
                        title: 'AI for Business',
                        rating: '4.9 ★',
                        meta: '฿1,990',
                        gradient: const [AppColors.primary, AppColors.secondary],
                        onTap: () => context.go('/course/c101'),
                      ),
                      _CourseCard(
                        title: 'Flutter Professional',
                        rating: '4.8 ★',
                        meta: '฿2,490',
                        gradient: const [AppColors.accent, AppColors.primary],
                        onTap: () => context.go('/course/c002'),
                      ),
                      _CourseCard(
                        title: 'Digital Marketing',
                        rating: '4.7 ★',
                        meta: '฿1,590',
                        gradient: const [Color(0xFF0EA5E9), AppColors.secondary],
                        onTap: () => context.go('/course/c103'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _SectionHeading(title: 'Live กำลังจะเริ่ม'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.35,
                    children: [
                      _CourseCard(
                        title: 'AI for Business — Live Q&A',
                        pillLabel: 'อีก 2 ชม.',
                        pillBg: AppColors.pillLiveBg,
                        pillText: AppColors.pillLiveText,
                        gradient: const [AppColors.accent, Color(0xFF0891B2)],
                        onTap: () => context.go('/live'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.active});
  final String active;

  static const _items = [
    ('Home', 'home', '/home'),
    ('Explore', 'explore', '/courses'),
    ('My Learning', 'learn', '/my-learning'),
    ('Live', 'live', '/live'),
    ('Community', 'community', '/community'),
    ('AI Tutor', 'ai', '/ai-tutor'),
    ('Career', 'career', '/career-path'),
    ('Portfolio', 'portfolio', '/portfolio'),
    ('Jobs', 'jobs', '/jobs'),
    ('Wallet', 'wallet', '/wallet'),
    ('Settings', 'settings', '/settings'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('AB LEARNING',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 22),
            for (final item in _items)
              _SidebarLink(
                label: item.$1,
                isActive: item.$2 == active,
                onTap: () => context.go(item.$3),
              ),
          ],
        ),
      );
}

class _SidebarLink extends StatelessWidget {
  const _SidebarLink({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: isActive ? AppColors.sidebarActiveBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
          ),
        ),
      );
}

class _TopRow extends StatelessWidget {
  const _TopRow();
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('สวัสดี, คุณอนันต์ 👋',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text('มาต่อการเรียนรู้ของวันนี้กันเถอะ',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const _CoinBadge(),
          const SizedBox(width: 12),
          const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text('A', style: TextStyle(color: Colors.white, fontSize: 12))),
        ],
      );
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: AppColors.pillWarnBg, borderRadius: BorderRadius.circular(999)),
        child: const Text('🪙 2,450',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pillWarnText)),
      );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTutor});
  final VoidCallback onTutor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('วันนี้อยากพัฒนาอะไร?',
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('ถาม AI Tutor เพื่อวางแผนการเรียนของคุณแบบเฉพาะบุคคล',
                style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 12.5)),
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.primary),
              onPressed: onTutor,
              child: const Text('ถาม AI Tutor →'),
            ),
          ],
        ),
      );
}

class _CareerProgressCard extends StatelessWidget {
  const _CareerProgressCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Career Path Progress',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            const Text('78%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: const LinearProgressIndicator(
                  value: 0.78, minHeight: 6, backgroundColor: AppColors.divider,
                  color: AppColors.primary),
            ),
          ],
        ),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) =>
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.title,
    required this.gradient,
    required this.onTap,
    this.rating,
    this.meta,
    this.pillLabel,
    this.pillBg,
    this.pillText,
  });

  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;
  final String? rating;
  final String? meta;
  final String? pillLabel;
  final Color? pillBg;
  final Color? pillText;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 96,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient)),
                  ),
                  if (pillLabel != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                            color: pillBg, borderRadius: BorderRadius.circular(999)),
                        child: Text(pillLabel!,
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: pillText)),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600)),
                    if (rating != null || meta != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rating ?? '',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                          Text(meta ?? '',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// MOBILE LAYOUT — matches 02-hifi-mockups.html `home.m`
// ---------------------------------------------------------------------------

class _MobileHome extends StatelessWidget {
  const _MobileHome();

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: [
            const _MobileTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _HeroCard(onTutor: () => context.go('/ai-tutor')),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _SectionHeading(title: 'เรียนต่อ'),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        SizedBox(
                          width: 230,
                          child: _CourseCard(
                            title: 'Go Backend Masterclass',
                            gradient: const [AppColors.primary, AppColors.secondary],
                            onTap: () => context.go('/course/c001'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: _SectionHeading(title: 'แนะนำสำหรับคุณ'),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        SizedBox(
                          width: 180,
                          child: _CourseCard(
                            title: 'AI for Business',
                            rating: '4.9 ★',
                            meta: '฿1,990',
                            gradient: const [AppColors.primary, AppColors.secondary],
                            onTap: () => context.go('/course/c101'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 180,
                          child: _CourseCard(
                            title: 'Flutter Professional',
                            rating: '4.8 ★',
                            meta: '฿2,490',
                            gradient: const [AppColors.accent, AppColors.primary],
                            onTap: () => context.go('/course/c002'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: _SectionHeading(title: 'Live กำลังจะเริ่ม'),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        SizedBox(
                          width: 210,
                          child: _CourseCard(
                            title: 'AI for Business — Live Q&A',
                            pillLabel: 'อีก 2 ชม.',
                            pillBg: AppColors.pillLiveBg,
                            pillText: AppColors.pillLiveText,
                            gradient: const [AppColors.accent, Color(0xFF0891B2)],
                            onTap: () => context.go('/live'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.divider))),
        child: Row(
          children: [
            const Expanded(
              child: Text('สวัสดี, คุณอนันต์ 👋',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded, size: 20)),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, size: 20)),
            const _CoinBadge(),
            const SizedBox(width: 10),
            const CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary,
                child: Text('A', style: TextStyle(color: Colors.white, fontSize: 11))),
          ],
        ),
      );
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav();

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider))),
        padding: const EdgeInsets.only(top: 9, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(icon: Icons.home_rounded, label: 'Home', active: true, onTap: () => context.go('/home')),
            _NavIcon(icon: Icons.explore_outlined, label: 'Explore', onTap: () => context.go('/courses')),
            _NavIcon(icon: Icons.school_outlined, label: 'Learn', onTap: () => context.go('/my-learning')),
            _NavIcon(icon: Icons.forum_outlined, label: 'Community', onTap: () => context.go('/community')),
            _NavIcon(icon: Icons.person_outline_rounded, label: 'Profile', onTap: () => context.go('/profile')),
          ],
        ),
      );
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.label, required this.onTap, this.active = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: active ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      );
}