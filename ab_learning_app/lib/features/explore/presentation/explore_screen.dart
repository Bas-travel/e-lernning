import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'recommended';
  final _searchController = TextEditingController();

  List<Course> get _filteredCourses {
    final query = _searchController.text.trim().toLowerCase();
    final results = MockRepository.courses.where((c) {
      final matchesCategory =
          _selectedCategory == 'All' || c.category == _selectedCategory;
      final searchableText =
          '${c.title} ${c.instructor} ${c.category} ${c.description}'
              .toLowerCase();
      final matchesQuery = query.isEmpty || searchableText.contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    if (_sortBy == 'rating') {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'price') {
      results.sort((a, b) =>
          _priceValue(a.priceLabel).compareTo(_priceValue(b.priceLabel)));
    }
    return results;
  }

  int _priceValue(String label) =>
      int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = _filteredCourses;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'ค้นหาคอร์ส, สกิล, อาจารย์...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _showSortOptions,
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('จัดเรียง'),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: MockRepository.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = MockRepository.categories[index];
                  final selected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                    selectedColor: AppColors.primary,
                    labelStyle: AppTypography.caption.copyWith(
                      color: selected ? Colors.white : AppColors.text,
                    ),
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(
                        side: BorderSide(color: AppColors.cardBorder)),
                  );
                },
              ),
            ),
            Expanded(
              child: courses.isEmpty
                  ? Center(
                      child: Text('ไม่พบคอร์สที่ตรงกับการค้นหา',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textSecondary)),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      children: [
                        if (_searchController.text.isEmpty &&
                            _selectedCategory == 'All') ...[
                          const Text('กำลังมาแรง', style: AppTypography.h2),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 158,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  courses.length < 2 ? courses.length : 2,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) =>
                                  _TrendingCourseCard(course: courses[index]),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('คอร์สทั้งหมด', style: AppTypography.h2),
                            Text('${courses.length} คอร์ส',
                                style: AppTypography.caption
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        for (final course in courses)
                          _CourseListCard(course: course),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSortOptions() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('จัดเรียงคอร์ส')),
            _SortOption(
              label: 'แนะนำ',
              selected: _sortBy == 'recommended',
              onTap: () => Navigator.pop(context, 'recommended'),
            ),
            _SortOption(
              label: 'คะแนนสูงสุด',
              selected: _sortBy == 'rating',
              onTap: () => Navigator.pop(context, 'rating'),
            ),
            _SortOption(
              label: 'ราคาต่ำสุด',
              selected: _sortBy == 'price',
              onTap: () => Navigator.pop(context, 'price'),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _sortBy = selected);
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? AppColors.primary : AppColors.textSecondary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _TrendingCourseCard extends StatelessWidget {
  const _TrendingCourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${course.coverColorHex}', radix: 16));
    return SizedBox(
      width: 190,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.push('/course/${course.id}'),
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
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [color, Color.lerp(color, Colors.black, 0.2)!]),
                  ),
                  child: const Icon(Icons.school_outlined,
                      color: Colors.white, size: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(course.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption
                                .copyWith(fontWeight: FontWeight.w600))),
                    const SizedBox(width: 6),
                    Text(course.rating.toStringAsFixed(1),
                        style: AppTypography.micro),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseListCard extends StatelessWidget {
  final Course course;

  const _CourseListCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${course.coverColorHex}', radix: 16));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.push('/course/${course.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 96,
                height: 88,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.card)),
                ),
                child: Icon(Icons.play_circle_fill, color: color, size: 32),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title,
                          style: AppTypography.h2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                          '${course.rating.toStringAsFixed(1)} ★ · ${course.priceLabel}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary)),
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
