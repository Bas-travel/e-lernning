import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../application/employer_controller.dart';
import '../models/employer_dashboard.dart';

class EmployerDemoStore {
  static final Set<int> shortlistedIds = {};
  static final List<String> jobs = ['Backend Developer', 'Product Designer'];
  static final Map<int, String> applicationStatuses = {3: 'Reviewing'};
}

class EmployerTalentScreen extends ConsumerWidget {
  const EmployerTalentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicants = ref.watch(topApplicantsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Talent Search')),
      body: applicants.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
            message: 'โหลดรายชื่อผู้สมัครไม่สำเร็จ',
            onRetry: () => ref.invalidate(topApplicantsProvider)),
        data: (people) => people.isEmpty
            ? const Center(child: Text('ยังไม่มีผู้สมัครที่ตรงกับเงื่อนไข'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('ผู้สมัครที่แนะนำ', style: AppTypography.h2),
                  const SizedBox(height: 6),
                  Text('จัดอันดับตามความเหมาะสมกับตำแหน่งงาน',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  for (final applicant in people)
                    _ApplicantCard(applicant: applicant),
                ],
              ),
      ),
    );
  }
}

class _ApplicantCard extends StatefulWidget {
  const _ApplicantCard({required this.applicant});
  final TopApplicant applicant;

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  @override
  Widget build(BuildContext context) {
    final applicant = widget.applicant;
    final isShortlisted =
        EmployerDemoStore.shortlistedIds.contains(applicant.userId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(applicant.name.characters.first,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(applicant.name,
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(applicant.headline,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary))
                    ])),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(AppRadius.badge)),
                    child: Text(
                        '${applicant.matchScore.toStringAsFixed(0)}% match',
                        style: const TextStyle(
                            color: Color(0xFF166534),
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 10),
            Text('เหมาะกับตำแหน่ง ${applicant.jobTitle}',
                style: AppTypography.caption),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () => _showProfile(context, applicant),
                        icon:
                            const Icon(Icons.person_search_outlined, size: 18),
                        label: const Text('ดูโปรไฟล์'))),
                const SizedBox(width: 8),
                Expanded(
                    child: FilledButton.icon(
                        onPressed: () => setState(() {
                              if (isShortlisted) {
                                EmployerDemoStore.shortlistedIds
                                    .remove(applicant.userId);
                              } else {
                                EmployerDemoStore.shortlistedIds
                                    .add(applicant.userId);
                              }
                            }),
                        icon: Icon(
                            isShortlisted
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            size: 18),
                        label:
                            Text(isShortlisted ? 'บันทึกแล้ว' : 'Shortlist'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProfile(BuildContext context, TopApplicant applicant) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant.name, style: AppTypography.h1),
                    const SizedBox(height: 5),
                    Text(applicant.headline,
                        style: AppTypography.body
                            .copyWith(color: AppColors.textSecondary)),
                    const Divider(height: 26),
                    Text('ตำแหน่งที่เหมาะสม: ${applicant.jobTitle}'),
                    Text(
                        'คะแนนความเหมาะสม: ${applicant.matchScore.toStringAsFixed(0)}%'),
                    const SizedBox(height: 16),
                    const Text('ข้อมูลผู้สมัครตัวอย่างจากระบบจัดอันดับ MVP',
                        style: AppTypography.caption)
                  ]))),
    );
  }
}

class EmployerJobsScreen extends ConsumerStatefulWidget {
  const EmployerJobsScreen({super.key});

  @override
  ConsumerState<EmployerJobsScreen> createState() => _EmployerJobsScreenState();
}

class _EmployerJobsScreenState extends ConsumerState<EmployerJobsScreen> {
  List<Map<String, dynamic>> _jobs = [];
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
      final jobs = await ref.read(apiClientProvider).getEmployerJobs();
      if (mounted) {
        setState(() {
          _jobs = jobs.cast<Map<String, dynamic>>();
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

  Future<void> _createJob() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final location = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('สร้างตำแหน่งงาน'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: title,
                    decoration:
                        const InputDecoration(labelText: 'ชื่อตำแหน่ง')),
                TextField(
                    controller: description,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'รายละเอียด')),
                TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'สถานที่'))
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('ยกเลิก')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('สร้าง'))
              ],
            ));
    if (accepted == true && title.text.trim().length >= 3) {
      try {
        await ref.read(apiClientProvider).createEmployerJob({
          'title': title.text.trim(),
          'description': description.text.trim(),
          'location': location.text.trim()
        });
        await _load();
      } catch (error) {
        if (mounted) {
          messenger.showSnackBar(
              SnackBar(content: Text('สร้างตำแหน่งไม่สำเร็จ: $error')));
        }
      }
    }
    title.dispose();
    description.dispose();
    location.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ตำแหน่งงาน')),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _createJob,
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มตำแหน่ง')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(
                    message: 'โหลดตำแหน่งงานไม่สำเร็จ: $_error', onRetry: _load)
                : _jobs.isEmpty
                    ? const Center(child: Text('ยังไม่มีตำแหน่งงาน'))
                    : ListView(padding: const EdgeInsets.all(16), children: [
                        for (final job in _jobs)
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.card),
                                  border:
                                      Border.all(color: AppColors.cardBorder)),
                              child: ListTile(
                                  leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFE0F2FE),
                                      child: Icon(Icons.work_outline,
                                          color: AppColors.accent)),
                                  title: Text('${job['title'] ?? 'ตำแหน่งงาน'}',
                                      style: AppTypography.body.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      '${job['location'] ?? '-'} · ${job['status'] ?? '-'}'),
                                  trailing: const Icon(Icons.chevron_right)))
                      ]),
      );
}

class EmployerApplicationsScreen extends ConsumerStatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  ConsumerState<EmployerApplicationsScreen> createState() =>
      _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState
    extends ConsumerState<EmployerApplicationsScreen> {
  static const _statuses = {
    'reviewed': 'ตรวจแล้ว',
    'shortlisted': 'Shortlist',
    'rejected': 'ปฏิเสธ',
    'hired': 'รับเข้าทำงาน'
  };
  List<Map<String, dynamic>> _applications = [];
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
      final rows = await ref.read(apiClientProvider).getEmployerApplications();
      if (mounted) {
        setState(() {
          _applications = rows.cast<Map<String, dynamic>>();
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ใบสมัคร')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(
                    message: 'โหลดใบสมัครไม่สำเร็จ: $_error', onRetry: _load)
                : _applications.isEmpty
                    ? const Center(child: Text('ยังไม่มีใบสมัคร'))
                    : ListView(padding: const EdgeInsets.all(16), children: [
                        for (final application in _applications)
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.card),
                                  border:
                                      Border.all(color: AppColors.cardBorder)),
                              child: ListTile(
                                leading: const CircleAvatar(
                                    child: Icon(Icons.person_outline)),
                                title: Text(
                                    '${application['name'] ?? application['email'] ?? 'ผู้สมัคร'}'),
                                subtitle: Text(
                                    '${application['job_title'] ?? '-'} · ${application['email'] ?? ''}'),
                                trailing: DropdownButton<String>(
                                    value: _statuses
                                            .containsKey(application['status'])
                                        ? application['status'] as String
                                        : 'reviewed',
                                    items: _statuses.entries
                                        .map((entry) => DropdownMenuItem(
                                            value: entry.key,
                                            child: Text(entry.value)))
                                        .toList(),
                                    onChanged: (status) async {
                                      if (status == null) return;
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      try {
                                        await ref
                                            .read(apiClientProvider)
                                            .updateEmployerApplication(
                                                (application['id'] as num)
                                                    .toInt(),
                                                status: status);
                                        await _load();
                                      } catch (error) {
                                        if (mounted) {
                                          messenger.showSnackBar(SnackBar(
                                              content: Text(
                                                  'ปรับสถานะไม่สำเร็จ: $error')));
                                        }
                                      }
                                    }),
                              )),
                      ]),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('ลองอีกครั้ง'))
      ]));
}
