import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/typography.dart';

class InstructorCourseBuilderScreen extends ConsumerStatefulWidget {
  const InstructorCourseBuilderScreen({required this.courseId, super.key});
  final int courseId;

  @override
  ConsumerState<InstructorCourseBuilderScreen> createState() =>
      _InstructorCourseBuilderScreenState();
}

class _InstructorCourseBuilderScreenState
    extends ConsumerState<InstructorCourseBuilderScreen> {
  Map<String, dynamic>? _course;
  bool _loading = true;
  bool _busy = false;
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
      final course = await ref
          .read(apiClientProvider)
          .getInstructorCourse(widget.courseId);
      if (mounted) {
        setState(() {
          _course = course;
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

  bool get _editable =>
      _course?['status'] == 'draft' || _course?['status'] == 'rejected';

  bool get _readyToSubmit {
    final sections = _course?['sections'] as List<dynamic>? ?? const [];
    final lessons = sections
        .cast<Map<String, dynamic>>()
        .expand((section) => section['lessons'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .toList();
    return lessons.isNotEmpty &&
        lessons.every((lesson) =>
            lesson['type'] != 'video' ||
            (lesson['video_url'] as String? ?? '').isNotEmpty);
  }

  Future<void> _addSection() async {
    final title = TextEditingController();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('เพิ่มบท'),
              content: TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'ชื่อบท')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('ยกเลิก')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('เพิ่ม'))
              ],
            ));
    if (accepted == true && title.text.trim().isNotEmpty) {
      await _perform(() async {
        final sections = _course?['sections'] as List<dynamic>? ?? const [];
        await ref.read(apiClientProvider).createInstructorSection({
          'course_id': widget.courseId,
          'title': title.text.trim(),
          'sort_order': sections.length + 1,
        });
      });
    }
    title.dispose();
  }

  Future<void> _addVideoLesson(Map<String, dynamic> section) async {
    final title = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('เพิ่มวิดีโอบทเรียน'),
              content: TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'ชื่อบทเรียน')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('ยกเลิก')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('เลือกวิดีโอ'))
              ],
            ));
    if (accepted != true || title.text.trim().isEmpty) {
      title.dispose();
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp4', 'webm'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('อ่านไฟล์วิดีโอไม่สำเร็จ');
      }
      if (file.size > 500 * 1024 * 1024) {
        throw StateError('ขนาดไฟล์ต้องไม่เกิน 500 MB');
      }
      await _perform(() async {
        final upload = await ref
            .read(apiClientProvider)
            .uploadInstructorVideo(bytes: bytes, filename: file.name);
        final lessons = section['lessons'] as List<dynamic>? ?? const [];
        await ref.read(apiClientProvider).createInstructorLesson({
          'section_id': (section['id'] as num).toInt(),
          'title': title.text.trim(),
          'type': 'video',
          'video_url': upload['url'],
          'duration_seconds': 0,
          'is_preview': false,
          'sort_order': lessons.length + 1,
        });
      });
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
            SnackBar(content: Text('เพิ่มวิดีโอไม่สำเร็จ: $error')));
      }
    } finally {
      title.dispose();
    }
  }

  Future<void> _submit() async {
    await _perform(() async {
      await ref.read(apiClientProvider).submitInstructorCourse(widget.courseId);
    });
    if (mounted && _error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ส่งคอร์สให้ผู้ดูแลตรวจสอบแล้ว')));
    }
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;
    final sections = (course?['sections'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return Scaffold(
      appBar:
          AppBar(title: Text(course?['title'] as String? ?? 'Course Builder')),
      floatingActionButton: _editable
          ? FloatingActionButton.extended(
              onPressed: _busy ? null : _addSection,
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มบท'))
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('ลองอีกครั้ง'))
                      ])))
              : ListView(padding: const EdgeInsets.all(16), children: [
                  Text('สถานะ: ${course?['status'] ?? 'draft'}',
                      style: AppTypography.caption),
                  const SizedBox(height: 12),
                  if (sections.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'เพิ่มบทและวิดีโอบทเรียนเพื่อเตรียมส่งตรวจสอบ')),
                  for (final section in sections)
                    Card(
                        child: ExpansionTile(
                      title: Text('${section['title'] ?? 'บทเรียน'}'),
                      subtitle: Text(
                          '${(section['lessons'] as List<dynamic>? ?? const []).length} บทเรียน'),
                      children: [
                        for (final lesson
                            in (section['lessons'] as List<dynamic>? ??
                                const []))
                          ListTile(
                              leading: const Icon(Icons.play_circle_outline),
                              title: Text('${lesson['title'] ?? ''}')),
                        if (_editable)
                          Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                  onPressed: _busy
                                      ? null
                                      : () => _addVideoLesson(section),
                                  icon:
                                      const Icon(Icons.video_library_outlined),
                                  label: const Text('เพิ่มวิดีโอ'))),
                      ],
                    )),
                  if (_editable && !_readyToSubmit)
                    const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                            'เพิ่มวิดีโอบทเรียนอย่างน้อยหนึ่งรายการก่อนส่งตรวจสอบ')),
                  if (_editable)
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: FilledButton.icon(
                            onPressed:
                                _busy || !_readyToSubmit ? null : _submit,
                            icon: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.send_outlined),
                            label: const Text('ส่งตรวจสอบ'))),
                  if (course?['status'] == 'pending_review')
                    const Text('คอร์สอยู่ระหว่างการตรวจสอบ'),
                  if (course?['status'] == 'published')
                    const Text('คอร์สนี้เผยแพร่แล้ว'),
                ]),
    );
  }
}
