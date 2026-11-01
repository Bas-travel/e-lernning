import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/nav_targets.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/hifi_text_field.dart';
import '../../../core/widgets/gradient_course_card.dart';
import '../../../core/widgets/responsive.dart';
import '../data/course_catalog_sample.dart';
import 'course_filter_sheet.dart';
import 'course_list_tile.dart';

const _searchHint = 'ค้นหาคอร์ส, สกิล, อาจารย์...';

class HifiExploreScreen extends StatefulWidget {
  const HifiExploreScreen({super.key});

  @override
  State<HifiExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<HifiExploreScreen> {
  int _category = 0;
  CourseFilter _filter = const CourseFilter();

  void _openSearch() => context.push('/search');

  Future<void> _openFilter() async {
    final result = await showCourseFilterSheet(context, _filter);
    if (result != null && mounted) setState(() => _filter = result);
  }

  List<CatalogCourse> get _filteredAll =>
      CourseCatalogSample.all.where(_filter.matches).toList();

  Widget _categoryChips(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AppChip(
              label: categories[i],
              active: i == _category,
              onTap: () => setState(() => _category = i),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(mobile: _buildMobile, desktop: _buildDesktop);
  }

  // ---------------------------------------------------------------- mobile

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: CenteredContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: HifiTextField(
                          hint: _searchHint,
                          readOnly: true,
                          onTap: _openSearch,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton.ghost(
                        label: _filter.isActive ? '☰ •' : '☰',
                        onPressed: _openFilter,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _categoryChips(
                    CourseCatalogSample.categories.take(6).toList(),
                  ),
                ),
                const _MobileSectionTitle('กำลังมาแรง'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0;
                            i < CourseCatalogSample.trending.length;
                            i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          _courseCard(
                            context,
                            CourseCatalogSample.trending[i],
                            width: 180,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const _MobileSectionTitle('คอร์สทั้งหมด'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final c in _filteredAll.skip(_filter.isActive ? 0 : 2)) ...[
                        CourseListTile(
                          course: c,
                          onTap: () => context.push('/course/${c.id}'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) => NavTargets.onTab(context, i),
      ),
    );
  }

  // --------------------------------------------------------------- desktop

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Not in the Explore mockup, but kept so desktop users can navigate.
          AppSidebar(
            activeKey: 'explore',
            onSelect: (k) => NavTargets.onSidebar(context, k),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: HifiTextField(
                            hint: _searchHint,
                            fontSize: 13.5,
                            readOnly: true,
                            onTap: _openSearch,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppButton.ghost(
                          label: _filter.isActive ? '☰ Filter •' : '☰ Filter',
                          onPressed: _openFilter,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _categoryChips(CourseCatalogSample.categories),
                    const SizedBox(height: 20),
                    Text(
                      'คอร์สทั้งหมด',
                      style: AppTypography.base(14, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    CardGrid(
                      columns: 4,
                      children: [
                        for (final c in _filteredAll) _courseCard(context, c),
                      ],
                    ),
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

Widget _courseCard(BuildContext context, CatalogCourse c, {double? width}) {
  return GradientCourseCard(
    width: width,
    title: c.title,
    gradient: c.gradient,
    meta: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(c.rating), Text(c.price)],
    ),
    onTap: () => context.push('/course/${c.id}'),
  );
}

class _MobileSectionTitle extends StatelessWidget {
  const _MobileSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Text(text, style: AppTypography.base(14, weight: FontWeight.w600)),
    );
  }
}
