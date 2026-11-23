import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../../../core/router/nav_targets.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/gradient_course_card.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/status_pill.dart';
import 'home_content.dart';
import 'home_sample_data.dart';

class HifiHomeScreen extends StatefulWidget {
  const HifiHomeScreen({super.key});

  @override
  State<HifiHomeScreen> createState() => _HifiHomeScreenState();
}

class _HifiHomeScreenState extends State<HifiHomeScreen> {
  HomeContent? _content;

  @override
  void initState() {
    super.initState();
    final repo = AppDependencies.catalogRepository;
    if (repo.bundledOnly) {
      _content = HomeContent.sample();
    } else {
      _load(repo);
    }
  }

  /// Falls back to the bundled demo content when the server has nothing
  /// (signed out, offline, error), so the screen is never blank.
  Future<void> _load(CatalogRepository repo) async {
    final feed = await repo.homeFeed();
    if (!mounted) return;
    setState(() {
      _content =
          feed == null ? HomeContent.sample() : HomeContent.fromFeed(feed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    if (content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = AppDependencies.authRepository.currentUser;
    final name = user?.displayName ?? HomeSampleData.userName;
    final initial = user?.initial ?? HomeSampleData.userInitial;
    return ResponsiveBuilder(
      mobile: (_) => _HomeMobile(
        name: name,
        initial: initial,
        content: content,
      ),
      desktop: (_) => _HomeDesktop(
        name: name,
        initial: initial,
        content: content,
      ),
    );
  }
}

// ---------------------------------------------------------------- mobile

class _HomeMobile extends StatelessWidget {
  const _HomeMobile({
    required this.name,
    required this.initial,
    required this.content,
  });

  final String name;
  final String initial;
  final HomeContent content;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'สวัสดี, $name 👋',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.base(14, weight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _UserActions(gap: 14, initial: initial),
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
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: _HeroCard(
                        titleSize: 14,
                        subtitleSize: 11.5,
                        subtitle: 'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณ',
                        buttonPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        buttonFontSize: 12,
                        titleGap: 4,
                        subtitleGap: 10,
                      ),
                    ),
                    if (content.continueItems.isNotEmpty) ...[
                      const _SectionTitle('เรียนต่อ', horizontalPadding: 16),
                      _ContinueRow(items: content.continueItems),
                    ],
                    if (content.recommended.isNotEmpty) ...[
                      const _SectionTitle(
                        'แนะนำสำหรับคุณ',
                        horizontalPadding: 16,
                      ),
                      _RecommendedRow(courses: content.recommended),
                    ],
                    if (content.live != null) ...[
                      const _SectionTitle(
                        'Live กำลังจะเริ่ม',
                        horizontalPadding: 16,
                      ),
                      _LiveRow(live: content.live!),
                    ],
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
        // Learn / Community / Profile tabs have no screens yet (ignored).
        onTap: (index) => NavTargets.onTab(context, index),
      ),
    );
  }
}

class _ContinueRow extends StatelessWidget {
  const _ContinueRow({required this.items});

  final List<HomeContinue> items;

  @override
  Widget build(BuildContext context) {
    return _HScroll(
      children: [
        for (final item in items)
          GradientCourseCard(
            width: 230,
            title: item.title,
            extra: AppProgressBar(value: item.progress),
            meta: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${(item.progress * 100).round()}% เสร็จแล้ว',
                    overflow: TextOverflow.ellipsis,
                  ),
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
            onTap: () => context.push(item.route),
          ),
      ],
    );
  }
}

class _RecommendedRow extends StatelessWidget {
  const _RecommendedRow({required this.courses});

  final List<HomeCourse> courses;

  @override
  Widget build(BuildContext context) {
    // Mockup (mobile) shows the first two recommended courses.
    return _HScroll(
      children: [
        for (final course in courses.take(2))
          _recommendedCard(context, course, width: 180),
      ],
    );
  }
}

class _LiveRow extends StatelessWidget {
  const _LiveRow({required this.live});

  final HomeLive live;

  @override
  Widget build(BuildContext context) {
    return _HScroll(children: [_liveCard(live, width: 180)]);
  }
}

// --------------------------------------------------------------- desktop

class _HomeDesktop extends StatelessWidget {
  const _HomeDesktop({
    required this.name,
    required this.initial,
    required this.content,
  });

  final String name;
  final String initial;
  final HomeContent content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            activeKey: 'home',
            onSelect: (key) => NavTargets.onSidebar(context, key),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
                              'สวัสดี, $name 👋',
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
                        _UserActions(gap: 16, initial: initial),
                      ],
                    ),
                    const SizedBox(height: 20),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: _HeroCard(
                              titleSize: 16,
                              subtitleSize: 12.5,
                              subtitle:
                                  'ถาม AI Tutor เพื่อวางแผนการเรียนของคุณแบบเฉพาะบุคคล',
                              buttonPadding: EdgeInsets.symmetric(
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
                                    '${(content.careerProgress * 100).round()}%',
                                    style: AppTypography.base(
                                      20,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  AppProgressBar(value: content.careerProgress),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (content.recommended.isNotEmpty) ...[
                      const _SectionTitle('แนะนำสำหรับคุณ'),
                      const SizedBox(height: 12),
                      CardGrid(
                        columns: 3,
                        children: [
                          for (final course in content.recommended)
                            _recommendedCard(context, course),
                        ],
                      ),
                    ],
                    if (content.live != null) ...[
                      const SizedBox(height: 22),
                      const _SectionTitle('Live กำลังจะเริ่ม'),
                      const SizedBox(height: 12),
                      CardGrid(
                          columns: 3, children: [_liveCard(content.live!)]),
                    ],
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
  return GradientCourseCard(
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

Widget _liveCard(HomeLive live, {double? width}) {
  return GradientCourseCard(
    width: width,
    title: live.title,
    gradient: AppGradients.live,
    meta: Row(
      children: [
        StatusPill(label: live.startsIn, variant: StatusPillVariant.live),
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
        const NotificationBell(),
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
