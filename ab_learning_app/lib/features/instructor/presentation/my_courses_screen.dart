import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';
import 'instructor_workflows.dart';

/// Screen 32 — My Courses. Status is derived from mock progress data since
/// the Course model doesn't carry a real workflow status yet (Phase 3 adds
/// `status` from `05-openapi.yaml`: draft/pending_review/published/rejected).
class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {

  Future<void> _createCourse() async {
    await context.push('/instructor/create-course');
    if (mounted) setState(() {});
  }

  static const _tabs = ['Published', 'Draft', 'Pending', 'Rejected'];

  String _statusFor(Course c) {
    if (c.progress >= 1.0) return 'Published';
    if (c.students > 5000) return 'Published';
    if (c.students > 0) return 'Pending';
    return 'Draft';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Courses'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createCourse,
          icon: const Icon(Icons.add),
          label: const Text('Create Course'),
        ),
        body: TabBarView(
          children: _tabs.map((tab) {
            if (tab == 'Draft' && InstructorDemoStore.drafts.isNotEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final draft in InstructorDemoStore.drafts)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.edit_note_outlined)),
                        title: Text(draft.title),
                        subtitle: Text('${draft.category} · ${draft.status}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/instructor/create-course'),
                      ),
                    ),
                  for (final c in MockRepository.courses.where((course) => _statusFor(course) == tab))
                    ListTile(title: Text(c.title), subtitle: const Text('Draft')),
                ],
              );
            }
            final courses = MockRepository.courses.where((c) => _statusFor(c) == tab).toList();
            if (courses.isEmpty) {
              return Center(
                child: Text('No $tab courses yet', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, i) {
                final c = courses[i];
                final color = Color(int.parse('FF${c.coverColorHex}', radix: 16));
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.button)),
                        child: Icon(Icons.menu_book_rounded, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              '${c.students} students · ★ ${c.rating.toStringAsFixed(1)} · ${c.priceLabel}',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                          PopupMenuItem(value: 'analytics', child: Text('Analytics')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
