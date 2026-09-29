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
  final _searchController = TextEditingController();

  List<Course> get _filteredCourses {
    final query = _searchController.text.trim().toLowerCase();
    return MockRepository.courses.where((c) {
      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesQuery = query.isEmpty || c.title.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = _filteredCourses;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search courses, instructors, skills...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
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
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    selectedColor: AppColors.primary,
                    labelStyle: AppTypography.caption.copyWith(
                      color: selected ? Colors.white : AppColors.text,
                    ),
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(side: BorderSide(color: AppColors.cardBorder)),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: courses.isEmpty
                  ? Center(
                      child: Text('No courses found', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) => _CourseListCard(course: courses[index]),
                    ),
            ),
          ],
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
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.card)),
                ),
                child: Icon(Icons.play_circle_fill, color: color, size: 32),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: AppTypography.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(course.instructor, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text('${course.rating}', style: AppTypography.caption),
                          const SizedBox(width: 8),
                          Text('· ${course.students} students', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
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
