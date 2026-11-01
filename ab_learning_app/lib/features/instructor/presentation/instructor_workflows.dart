import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';

class InstructorDraft {
  InstructorDraft(
      {required this.title,
      required this.category,
      required this.description,
      this.status = 'Draft'});
  final String title;
  final String category;
  final String description;
  String status;
  final DateTime createdAt = DateTime.now();
}

class InstructorDemoStore {
  static final drafts = <InstructorDraft>[];
}

class InstructorCreateCourseScreen extends ConsumerStatefulWidget {
  const InstructorCreateCourseScreen({super.key});

  @override
  ConsumerState<InstructorCreateCourseScreen> createState() =>
      _InstructorCreateCourseScreenState();
}

class _InstructorCreateCourseScreenState
    extends ConsumerState<InstructorCreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  int? _categoryId;
  bool _submitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final rows = await ref.read(apiClientProvider).getCategories();
      if (mounted) {
        setState(() {
          _categories = rows.cast<Map<String, dynamic>>();
          _categoryId = _categories.isEmpty
              ? null
              : (_categories.first['id'] as num).toInt();
        });
      }
    } catch (error) {
      if (mounted) setState(() => _loadError = error.toString());
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ยังไม่มีหมวดหมู่ให้เลือก')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final course = await ref.read(apiClientProvider).createInstructorCourse({
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'category_id': _categoryId,
        'level': 'beginner',
        'language': 'th',
        'thumbnail_url': '',
        'price': 0,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'บันทึกฉบับร่างแล้ว · เพิ่มบทเรียนและวิดีโอก่อนส่งตรวจสอบ')));
      context.pop((course['id'] as num?)?.toInt());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $error')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('สร้างคอร์ส')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(padding: const EdgeInsets.all(20), children: [
                const Text('รายละเอียดคอร์ส', style: AppTypography.h1),
                const SizedBox(height: 6),
                Text('สร้างฉบับร่างและส่งให้ผู้ดูแลตรวจสอบก่อนเผยแพร่',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 22),
                TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(
                        labelText: 'ชื่อคอร์ส',
                        hintText: 'เช่น Go Backend Essentials'),
                    validator: (value) =>
                        value == null || value.trim().length < 5
                            ? 'กรอกชื่อคอร์สอย่างน้อย 5 ตัวอักษร'
                            : null),
                const SizedBox(height: 14),
                if (_loadError != null)
                  Text('โหลดหมวดหมู่ไม่สำเร็จ: $_loadError',
                      style: const TextStyle(color: Colors.red)),
                DropdownButtonFormField<int>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                    items: _categories
                        .map((category) => DropdownMenuItem(
                            value: (category['id'] as num).toInt(),
                            child: Text(
                                '${category['name_th'] ?? category['name_en'] ?? category['name'] ?? 'Category'}')))
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value)),
                const SizedBox(height: 14),
                TextFormField(
                    controller: _description,
                    minLines: 4,
                    maxLines: 7,
                    decoration: const InputDecoration(
                        labelText: 'คำอธิบายคอร์ส', alignLabelWithHint: true),
                    validator: (value) =>
                        value == null || value.trim().length < 20
                            ? 'คำอธิบายควรมีอย่างน้อย 20 ตัวอักษร'
                            : null),
                const SizedBox(height: 14),
                Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Text(
                        'บันทึกคอร์สลง API เป็นฉบับร่างได้ การส่งตรวจสอบต้องเพิ่มบทเรียนและวิดีโอก่อน',
                        style:
                            TextStyle(color: Color(0xFF78350F), fontSize: 12))),
                const SizedBox(height: 20),
                FilledButton.icon(
                    onPressed:
                        _submitting || _categories.isEmpty ? null : _save,
                    icon: _submitting
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: const Text('บันทึกฉบับร่าง')),
              ]),
            ),
          ),
        ),
      );
}

class InstructorLiveScreen extends StatelessWidget {
  const InstructorLiveScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Live Sessions')),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.podcasts_outlined,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  const Text('ถ่ายทอดสดยังไม่พร้อมใช้งาน',
                      style: AppTypography.h2),
                  const SizedBox(height: 6),
                  Text('การสตรีมต้องเชื่อมต่อบริการวิดีโอและสิทธิ์อุปกรณ์ก่อน',
                      textAlign: TextAlign.center,
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                      onPressed: () => context.push('/instructor/courses'),
                      icon: const Icon(Icons.video_library_outlined),
                      label: const Text('จัดการคอร์ส'))
                ]))),
      );
}

class InstructorAnalyticsScreen extends StatelessWidget {
  const InstructorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Course Analytics')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          for (final course in MockRepository.courses.take(4))
            Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.cardBorder)),
                child: ListTile(
                    leading: const Icon(Icons.insights_outlined,
                        color: AppColors.primary),
                    title: Text(course.title),
                    subtitle: Text(
                        '${course.students} ผู้เรียน · คะแนน ${course.rating.toStringAsFixed(1)}'),
                    trailing: Text(course.progress > 0
                        ? '${(course.progress * 100).round()}%'
                        : 'ขาย ${course.priceLabel}')))
        ]),
      );
}

class InstructorCourseDetailsScreen extends StatelessWidget {
  const InstructorCourseDetailsScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context) {
    final course = MockRepository.courseById(courseId);
    return Scaffold(
        appBar: AppBar(title: const Text('Course Overview')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text(course.title, style: AppTypography.h1),
          const SizedBox(height: 8),
          Text(course.description, style: AppTypography.body),
          const SizedBox(height: 16),
          Text(
              '${course.totalLessons} lessons · ${course.students} learners · ${course.rating.toStringAsFixed(1)} ★',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          FilledButton.icon(
              onPressed: () => context.push('/instructor/analytics'),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('ดู Analytics')),
          const SizedBox(height: 8),
          OutlinedButton.icon(
              onPressed: () => context.push('/instructor/create-course'),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('สร้างฉบับแก้ไข')),
        ]));
  }
}
