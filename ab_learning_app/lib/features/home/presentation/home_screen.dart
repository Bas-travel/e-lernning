import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/status_pill.dart';
import 'home_sample_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const _HomeMobile(),
      desktop: (_) => const _HomeDesktop(),
    );
  }
}

// ---------------------------------------------------------------- mobile

class _HomeMobile extends StatelessWidget {
  const _HomeMobile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'สวัสดี, ${HomeSampleData.userName} 👋',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.base(14, weight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _UserActions(gap: 14),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: CenteredContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _HeroCard(
                        titleSize: 14,
                        subtitleSize: 11.5,
                        subtitle: 'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณ',
                        buttonPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        buttonFontSize: 12,
                        titleGap: 4,
                        subtitleGap: 10,
                      ),
                    ),
                    const _SectionTitle('เรียนต่อ', horizontalPadding: 16),
                    const _ContinueRow(),
                    const _SectionTitle('แนะนำสำหรับคุณ', horizontalPadding: 16),
                    const _RecommendedRow(),
                    const _SectionTitle(
                      'Live กำลังจะเริ่ม',
                      horizontalPadding: 16,
                    ),
                    const _LiveRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Only Home exists in the router so far; other tabs are not routed yet.
          if (index == 0) context.go('/home');
        },
      ),
    );
  }
}

class _ContinueRow extends StatelessWidget {
  const _ContinueRow();

  @override
  Widget build(BuildContext context) {
    return _HScroll(
      children: [
        CourseCard(
          width: 230,
          title: HomeSampleData.continueTitle,
          extra: const AppProgressBar(value: HomeSampleData.continueProgress),
          meta: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('68% เสร็จแล้ว', overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(
                'เรียนต่อ',
                style: AppTypography.base(
                  11,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
            ],
          ),
          onTap: () =>
              context.push('/player/${HomeSampleData.continueLessonId}'),
        ),
      ],
    );
  }
}

class _RecommendedRow extends StatelessWidget {
  const _RecommendedRow();

  @override
  Widget build(BuildContext context) {
    // Mockup (mobile) shows the first two recommended courses.
    return _HScroll(
      children: [
        for (final course in HomeSampleData.recommended.take(2))
          _recommendedCard(context, course, width: 180),
      ],
    );
  }
}

class _LiveRow extends StatelessWidget {
  const _LiveRow();

  @override
  Widget build(BuildContext context) {
    return _HScroll(children: [_liveCard(width: 180)]);
  }
}

// --------------------------------------------------------------- desktop

class _HomeDesktop extends StatelessWidget {
  const _HomeDesktop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            activeKey: 'home',
            onSelect: (key) {
              if (key == 'home') context.go('/home');
            },
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'สวัสดี, ${HomeSampleData.userName} 👋',
                              style: AppTypography.base(
                                19,
                                weight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'มาต่อการเรียนรู้ของวันนี้กันเถอะ',
                              style: AppTypography.base(
                                12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const _UserActions(gap: 16),
                      ],
                    ),
                    const SizedBox(height: 20),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _HeroCard(
                              titleSize: 16,
                              subtitleSize: 12.5,
                              subtitle:
                                  'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณแบบเฉพาะบุคคล',
                              buttonPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              buttonFontSize: 12.5,
                              titleGap: 6,
                              subtitleGap: 14,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Career Path Progress',
                                    style: AppTypography.base(
                                      12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(HomeSampleData.careerProgress * 100).round()}%',
                                    style: AppTypography.base(
                                      20,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const AppProgressBar(
                                    value: HomeSampleData.careerProgress,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const _SectionTitle('แนะนำสำหรับคุณ'),
                    const SizedBox(height: 12),
                    CardGrid(
                      columns: 3,
                      children: [
                        for (final course in HomeSampleData.recommended)
                          _recommendedCard(context, course),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SectionTitle('Live กำลังจะเริ่ม'),
                    const SizedBox(height: 12),
                    CardGrid(columns: 3, children: [_liveCard()]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- shared

Widget _recommendedCard(
  BuildContext context,
  HomeCourse course, {
  double? width,
}) {
  return CourseCard(
    width: width,
    title: course.title,
    gradient: course.gradient,
    meta: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(course.rating), Text(course.price)],
    ),
    onTap: () => context.push('/course/${course.id}'),
  );
}

Widget _liveCard({double? width}) {
  return CourseCard(
    width: width,
    title: HomeSampleData.liveTitle,
    gradient: AppGradients.live,
    meta: const Row(
      children: [
        StatusPill(
          label: HomeSampleData.liveStartsIn,
          variant: StatusPillVariant.live,
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.horizontalPadding = 0});

  final String text;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        // Mobile mockup: margin 18px 0 10px. Desktop spacing is handled by the
        // caller (collapsed margins), so no extra top space is added there.
        horizontalPadding > 0 ? 18 : 0,
        horizontalPadding,
        horizontalPadding > 0 ? 10 : 0,
      ),
      child: Text(
        text,
        style: AppTypography.base(14, weight: FontWeight.w600),
      ),
    );
  }
}

class _HScroll extends StatelessWidget {
  const _HScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
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
          // TODO(nav): AI Tutor route (screen 21) does not exist in the router yet.
          AppButton.inverse(
            label: 'ถาม AI Tutor →',
            onPressed: () {},
            fontSize: buttonFontSize,
            padding: buttonPadding,
          ),
        ],
      ),
    );
  }
}

class _UserActions extends StatelessWidget {
  const _UserActions({required this.gap});

  final double gap;

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
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            HomeSampleData.userInitial,
            style: AppTypography.base(
              12,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
