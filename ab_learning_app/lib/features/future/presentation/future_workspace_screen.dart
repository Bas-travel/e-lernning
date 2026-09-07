import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Shared, responsive prototype surface for the Sprint 7–10 role workflows.
class FutureWorkspaceScreen extends StatefulWidget {
  const FutureWorkspaceScreen({super.key, required this.area});

  final String area;

  @override
  State<FutureWorkspaceScreen> createState() => _FutureWorkspaceScreenState();
}

class _FutureWorkspaceScreenState extends State<FutureWorkspaceScreen> {
  final _question = TextEditingController();
  String? _answer;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(widget.area);
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(content.headline, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(content.description, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              if (widget.area == 'ai') _aiTutor() else _dashboard(content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aiTutor() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Suggested: อธิบาย REST API ให้เข้าใจง่ายหน่อย', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(controller: _question, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ask AB AI Tutor...')),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => setState(() => _answer = 'REST API คือวิธีที่แอปคุยกันผ่าน HTTP โดยจัดข้อมูลเป็น resource เช่น /courses แล้วใช้ GET เพื่ออ่าน และ POST เพื่อสร้างข้อมูล ลองเริ่มจากออกแบบ URL และ response ให้สม่ำเสมอครับ'),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Ask Tutor'),
                ),
              ]),
            ),
          ),
          if (_answer != null) Card(color: const Color(0xFFEEF2FF), child: Padding(padding: const EdgeInsets.all(16), child: Text(_answer!))),
        ],
      );

  Widget _dashboard(_WorkspaceContent content) => Column(
        children: [
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 700 ? 3 : 2,
            childAspectRatio: 1.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: content.metrics.map((metric) => _metric(metric)).toList(),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(content.actionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...content.items.map((item) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle_outline, color: AppColors.primary), title: Text(item), trailing: const Icon(Icons.chevron_right))),
                Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved successfully'))), child: Text(content.cta))),
              ]),
            ),
          ),
        ],
      );

  Widget _metric(_Metric metric) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(metric.label, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(metric.value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          ]),
        ),
      );
}

_WorkspaceContent _contentFor(String area) {
  switch (area) {
    case 'assessment': return const _WorkspaceContent('Skill Assessment', 'Discover your next skill gap', 'Answer 20 questions to build a tailored learning path.', [_Metric('Overall score', '72%'), _Metric('Backend', '80%'), _Metric('Cloud', '48%')], 'Recommended learning plan', ['Docker & Kubernetes', 'SQL Masterclass', 'Practice API testing'], 'View career path');
    case 'career': return const _WorkspaceContent('Career Path', 'Senior Backend Developer · 78%', 'Learn, prove your skills, and find an opportunity.', [_Metric('Required skills', '5'), _Metric('Completed', '3'), _Metric('Course progress', '78%')], 'Your next milestones', ['Finish Docker fundamentals', 'Build a REST API project', 'Publish portfolio'], 'Find jobs');
    case 'portfolio': return const _WorkspaceContent('Portfolio', 'Your proof of skills', 'Keep your projects, certificates, and career story ready to share.', [_Metric('Projects', '3'), _Metric('Certificates', '2'), _Metric('Skills', '8')], 'Featured projects', ['Learning API · Go + PostgreSQL', 'Course dashboard · Flutter', 'Add your next project'], 'Edit portfolio');
    case 'jobs': return const _WorkspaceContent('Jobs', 'Opportunities matched to you', 'Your Backend Developer match is 92%.', [_Metric('Recommended', '12'), _Metric('Best match', '92%'), _Metric('Applications', '2')], 'Recommended roles', ['Backend Developer · ABC Technology', 'Platform Engineer · XYZ Finance', 'Software Engineer · Remote'], 'Apply now');
    case 'corporate': return const _WorkspaceContent('Corporate Dashboard', 'Learning progress across your organization', 'Track engagement, completion, and skill gaps in one place.', [_Metric('Employees', '500'), _Metric('Active learners', '312'), _Metric('Completion rate', '74%')], 'Team actions', ['Engineering · 68% completion', 'Product · 81% completion', 'Create Backend Onboarding path'], 'Manage employees');
    default: return const _WorkspaceContent('Admin Dashboard', 'Platform operations overview', 'Moderate users, courses, payments, and audit activity.', [_Metric('Users', '24,580'), _Metric('Pending courses', '4'), _Metric('Revenue', '฿1.28M')], 'Needs review', ['Advanced Go · pending approval', 'ORD001 · payment paid', 'Audit: course approved'], 'Open moderation');
  }
}

class _WorkspaceContent {
  const _WorkspaceContent(this.title, this.headline, this.description, this.metrics, this.actionTitle, this.items, this.cta);
  final String title, headline, description, actionTitle, cta;
  final List<_Metric> metrics;
  final List<String> items;
}

class _Metric { const _Metric(this.label, this.value); final String label, value; }
