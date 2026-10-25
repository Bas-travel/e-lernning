import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/nav_targets.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/responsive.dart';
import '../data/course_catalog_sample.dart';
import 'course_list_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<CatalogCourse> get _results => CourseCatalogSample.search(_controller.text);

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(mobile: _buildMobile, desktop: _buildDesktop);
  }

  Widget _buildMobile(BuildContext context) {
    final results = _results;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: CenteredContent(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Back arrow is not in the mockup; kept for navigation.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _back,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: AppTextField(
                          controller: _controller,
                          hint: 'ค้นหาคอร์ส, สกิล, อาจารย์...',
                          autofocus: widget.initialQuery.isEmpty,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ผลการค้นหา (${results.length})',
                    style: AppTypography.base(14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  for (final c in results) ...[
                    CourseListTile(
                      course: c,
                      thumbWidth: 70,
                      thumbHeight: 50,
                      thumbRadius: 8,
                      onTap: () => context.push('/course/${c.id}'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            activeKey: 'explore',
            onSelect: (k) => NavTargets.onSidebar(context, k),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: AppTextField(
                          controller: _controller,
                          hint: 'ค้นหาคอร์ส, สกิล, อาจารย์...',
                          fontSize: 14,
                          autofocus: widget.initialQuery.isEmpty,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.text.trim().isEmpty
                          ? 'พบ ${results.length} ผลลัพธ์'
                          : 'พบ ${results.length} ผลลัพธ์สำหรับ "${_controller.text.trim()}"',
                      style: AppTypography.base(
                        12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CardGrid(
                      columns: 3,
                      children: [
                        for (final c in results)
                          CourseCard(
                            title: c.title,
                            gradient: c.gradient,
                            meta: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text(c.rating), Text(c.price)],
                            ),
                            onTap: () => context.push('/course/${c.id}'),
                          ),
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
