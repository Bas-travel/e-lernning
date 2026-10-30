import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';

/// Instructor course list backed by the authenticated instructor API.
class MyCoursesScreen extends ConsumerStatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  ConsumerState<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends ConsumerState<MyCoursesScreen> {
  static const _tabs = <String, String>{
    'Published': 'published',
    'Draft': 'draft',
    'Pending': 'pending_review',
    'Rejected': 'rejected',
  };

  List<Map<String, dynamic>> _courses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).getInstructorCourses();
      if (mounted) {
        setState(() {
          _courses = rows.cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _createCourse() async {
    final courseId = await context.push<int>('/instructor/create-course');
    if (!mounted) return;
    await _load();
    if (courseId != null && mounted) {
      await context.push('/instructor/course-builder/$courseId');
      if (mounted) await _load();
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Courses'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Published'),
                Tab(text: 'Draft'),
                Tab(text: 'Pending'),
                Tab(text: 'Rejected')
              ],
            ),
            actions: [
              IconButton(
                  onPressed: _load,
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh))
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createCourse,
            icon: const Icon(Icons.add),
            label: const Text('Create Course'),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('โหลดคอร์สไม่สำเร็จ: $_error',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh),
                                label: const Text('ลองอีกครั้ง'))
                          ])))
                  : TabBarView(
                      children: _tabs.entries.map((tab) {
                      final courses = _courses
                          .where((course) => course['status'] == tab.value)
                          .toList();
                      if (courses.isEmpty) {
                        return Center(
                            child: Text('No ${tab.key} courses yet',
                                style: AppTypography.body
                                    .copyWith(color: AppColors.textSecondary)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            onTap: () => context.push(
                                '/instructor/course-builder/${course['id']}'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.card),
                                  border:
                                      Border.all(color: AppColors.cardBorder)),
                              child: Row(children: [
                                Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.button)),
                                    child: const Icon(Icons.menu_book_rounded,
                                        color: AppColors.primary)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                          '${course['title'] ?? 'Untitled course'}',
                                          style: AppTypography.body.copyWith(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${course['category'] ?? '—'} · ${course['lesson_count'] ?? 0} lessons · ${course['student_count'] ?? 0} students',
                                          style: AppTypography.caption.copyWith(
                                              color: AppColors.textSecondary)),
                                      if (course['rejected_reason'] is String &&
                                          (course['rejected_reason'] as String)
                                              .isNotEmpty)
                                        Text(
                                            'เหตุผล: ${course['rejected_reason']}',
                                            style: AppTypography.caption
                                                .copyWith(
                                                    color: AppColors.warning)),
                                    ])),
                                Chip(label: Text(tab.key)),
                              ]),
                            ),
                          );
                        },
                      );
                    }).toList()),
        ),
      );
}
