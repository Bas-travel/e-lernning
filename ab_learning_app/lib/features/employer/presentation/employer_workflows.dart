import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        error: (error, _) => _ErrorState(message: 'โหลดรายชื่อผู้สมัครไม่สำเร็จ', onRetry: () => ref.invalidate(topApplicantsProvider)),
        data: (people) => people.isEmpty
            ? const Center(child: Text('ยังไม่มีผู้สมัครที่ตรงกับเงื่อนไข'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('ผู้สมัครที่แนะนำ', style: AppTypography.h2),
                  const SizedBox(height: 6),
                  Text('จัดอันดับตามความเหมาะสมกับตำแหน่งงาน', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  for (final applicant in people) _ApplicantCard(applicant: applicant),
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
    final isShortlisted = EmployerDemoStore.shortlistedIds.contains(applicant.userId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(applicant.name.characters.first, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(applicant.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)), Text(applicant.headline, style: AppTypography.caption.copyWith(color: AppColors.textSecondary))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(AppRadius.badge)), child: Text('${applicant.matchScore.toStringAsFixed(0)}% match', style: const TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 10),
            Text('เหมาะกับตำแหน่ง ${applicant.jobTitle}', style: AppTypography.caption),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => _showProfile(context, applicant), icon: const Icon(Icons.person_search_outlined, size: 18), label: const Text('ดูโปรไฟล์'))),
                const SizedBox(width: 8),
                Expanded(child: FilledButton.icon(onPressed: () => setState(() { if (isShortlisted) { EmployerDemoStore.shortlistedIds.remove(applicant.userId); } else { EmployerDemoStore.shortlistedIds.add(applicant.userId); } }), icon: Icon(isShortlisted ? Icons.bookmark : Icons.bookmark_add_outlined, size: 18), label: Text(isShortlisted ? 'บันทึกแล้ว' : 'Shortlist'))),
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
      builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(applicant.name, style: AppTypography.h1), const SizedBox(height: 5), Text(applicant.headline, style: AppTypography.body.copyWith(color: AppColors.textSecondary)), const Divider(height: 26), Text('ตำแหน่งที่เหมาะสม: ${applicant.jobTitle}'), Text('คะแนนความเหมาะสม: ${applicant.matchScore.toStringAsFixed(0)}%'), const SizedBox(height: 16), const Text('ข้อมูลผู้สมัครตัวอย่างจากระบบจัดอันดับ MVP', style: AppTypography.caption)]))),
    );
  }
}

class EmployerJobsScreen extends StatefulWidget {
  const EmployerJobsScreen({super.key});

  @override
  State<EmployerJobsScreen> createState() => _EmployerJobsScreenState();
}

class _EmployerJobsScreenState extends State<EmployerJobsScreen> {
  Future<void> _createJob() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: const Text('สร้างตำแหน่งงาน'), content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'ชื่อตำแหน่ง')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('สร้าง'))]));
    controller.dispose();
    if (title == null || title.isEmpty || !mounted) return;
    setState(() => EmployerDemoStore.jobs.insert(0, title));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ตำแหน่งงาน')),
    floatingActionButton: FloatingActionButton.extended(onPressed: _createJob, icon: const Icon(Icons.add), label: const Text('เพิ่มตำแหน่ง')),
    body: ListView(padding: const EdgeInsets.all(16), children: [for (final job in EmployerDemoStore.jobs) Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.cardBorder)), child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2FE), child: Icon(Icons.work_outline, color: AppColors.accent)), title: Text(job, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)), subtitle: const Text('ประกาศ · ข้อมูลตัวอย่าง'), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เปิดตำแหน่ง $job'))))) ]),
  );
}

class EmployerApplicationsScreen extends StatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  State<EmployerApplicationsScreen> createState() => _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends State<EmployerApplicationsScreen> {
  static const _statuses = ['Reviewing', 'Shortlisted', 'Interview', 'Rejected'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ใบสมัคร')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      for (final entry in EmployerDemoStore.applicationStatuses.entries)
        Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.cardBorder)), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person_outline)), title: const Text('Anan Suksawat'), subtitle: const Text('Backend Developer · สมัครวันนี้'), trailing: DropdownButton<String>(value: entry.value, items: _statuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(), onChanged: (value) { if (value != null) setState(() => EmployerDemoStore.applicationStatuses[entry.key] = value); }))),
      if (EmployerDemoStore.applicationStatuses.isEmpty) const Center(child: Text('ยังไม่มีใบสมัคร')),
    ]),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(message), const SizedBox(height: 8), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('ลองอีกครั้ง'))]));
}
