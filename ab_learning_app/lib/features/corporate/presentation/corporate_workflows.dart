import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/current_user.dart';
import '../../../core/navigation/role_menus.dart';

class CorporateEmployee {
  CorporateEmployee({required this.name, required this.email, required this.department, this.active = true});
  final String name;
  final String email;
  final String department;
  bool active;
}

class LearningAssignment {
  LearningAssignment({required this.title, required this.department, required this.dueDate});
  final String title;
  final String department;
  final DateTime dueDate;
}

class CorporateDemoStore {
  static final employees = <CorporateEmployee>[
    CorporateEmployee(name: 'Narin Pongsak', email: 'narin@abc-tech.co', department: 'Engineering'),
    CorporateEmployee(name: 'Pimchanok Sae-Tang', email: 'pimchanok@abc-tech.co', department: 'Design'),
    CorporateEmployee(name: 'Thanawat K.', email: 'thanawat@abc-tech.co', department: 'Sales'),
  ];
  static final learningPaths = <LearningAssignment>[
    LearningAssignment(title: 'Cloud Engineering Foundations', department: 'Engineering', dueDate: DateTime.now().add(const Duration(days: 30))),
    LearningAssignment(title: 'Data Literacy for Teams', department: 'All departments', dueDate: DateTime.now().add(const Duration(days: 45))),
  ];
}

class CorporateEmployeesScreen extends StatefulWidget {
  const CorporateEmployeesScreen({super.key});

  @override
  State<CorporateEmployeesScreen> createState() => _CorporateEmployeesScreenState();
}

class _CorporateEmployeesScreenState extends State<CorporateEmployeesScreen> {
  final _searchController = TextEditingController();
  String _department = 'ทั้งหมด';
  static const _departments = ['ทั้งหมด', 'Engineering', 'Design', 'Sales'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addEmployee() async {
    final name = TextEditingController();
    final email = TextEditingController();
    String department = 'Engineering';
    final result = await showDialog<CorporateEmployee>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('เพิ่มพนักงาน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'ชื่อ-นามสกุล')),
              TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'อีเมลบริษัท')),
              DropdownButtonFormField<String>(
                initialValue: department,
                decoration: const InputDecoration(labelText: 'แผนก'),
                items: _departments.skip(1).map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setDialogState(() => department = value ?? department),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty || !_validEmail(email.text)) return;
                Navigator.pop(dialogContext, CorporateEmployee(name: name.text.trim(), email: email.text.trim(), department: department, active: false));
              },
              child: const Text('เพิ่มพนักงาน'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    email.dispose();
    if (result == null || !mounted) return;
    setState(() => CorporateDemoStore.employees.add(result));
  }

  bool get _canManageEmployees => CurrentUser.role == AppRole.corpAdmin;

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final employees = CorporateDemoStore.employees.where((employee) {
      final matchesDepartment = _department == 'ทั้งหมด' || employee.department == _department;
      final matchesQuery = query.isEmpty || '${employee.name} ${employee.email}'.toLowerCase().contains(query);
      return matchesDepartment && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('พนักงาน')),
      floatingActionButton: _canManageEmployees
          ? FloatingActionButton.extended(onPressed: _addEmployee, icon: const Icon(Icons.person_add_alt_1), label: const Text('เพิ่มพนักงาน'))
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ค้นหาชื่อหรืออีเมล'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _departments.map((department) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(department), selected: _department == department, onSelected: (_) => setState(() => _department = department)),
              )).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Text('${employees.length} คน · สิทธิ์ ${_canManageEmployees ? 'จัดการ' : 'ดูอย่างเดียว'}', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          for (final employee in employees) _EmployeeTile(employee: employee, canManage: _canManageEmployees, onChanged: () => setState(() {})),
        ],
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.canManage, required this.onChanged});
  final CorporateEmployee employee;
  final bool canManage;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.cardBorder)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(employee.name[0], style: const TextStyle(color: AppColors.primary))),
        title: Text(employee.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('${employee.email} · ${employee.department}', maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: canManage
            ? Switch(value: employee.active, onChanged: (value) { employee.active = value; onChanged(); })
            : Text(employee.active ? 'Active' : 'Invited', style: AppTypography.micro.copyWith(color: employee.active ? AppColors.success : AppColors.warning)),
      ),
    );
  }
}

class CorporateLearningPathsScreen extends StatefulWidget {
  const CorporateLearningPathsScreen({super.key});

  @override
  State<CorporateLearningPathsScreen> createState() => _CorporateLearningPathsScreenState();
}

class _CorporateLearningPathsScreenState extends State<CorporateLearningPathsScreen> {
  Future<void> _createPath() async {
    final title = TextEditingController();
    String department = 'Engineering';
    final result = await showDialog<LearningAssignment>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('สร้าง Learning Path'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'ชื่อเส้นทางการเรียน')),
              DropdownButtonFormField<String>(
                initialValue: department,
                decoration: const InputDecoration(labelText: 'มอบหมายให้'),
                items: const ['Engineering', 'Design', 'Sales', 'All departments'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setDialogState(() => department = value ?? department),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, LearningAssignment(title: title.text.trim(), department: department, dueDate: DateTime.now().add(const Duration(days: 30))));
              },
              child: const Text('สร้างเส้นทาง'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    if (result == null || !mounted) return;
    setState(() => CorporateDemoStore.learningPaths.insert(0, result));
  }

  void _showPathDetail(LearningAssignment path) {
    final due = path.dueDate;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(path.title),
        content: Text(
          'มอบหมายให้ ${path.department}\n'
          'กำหนดส่ง ${due.day}/${due.month}/${due.year}\n\n'
          'นี่คือข้อมูลตัวอย่างใน MVP',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Paths')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPath,
        icon: const Icon(Icons.add),
        label: const Text('สร้างเส้นทาง'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('เส้นทางการเรียนขององค์กร', style: AppTypography.h2),
          const SizedBox(height: 12),
          for (final path in CorporateDemoStore.learningPaths)
            _LearningPathCard(
              path: path,
              onDetail: () => _showPathDetail(path),
            ),
        ],
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  const _LearningPathCard({required this.path, required this.onDetail});
  final LearningAssignment path;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final due = path.dueDate;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0E7FF),
          child: Icon(Icons.route_outlined, color: AppColors.primary),
        ),
        title: Text(
          path.title,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${path.department} · กำหนดส่ง ${due.day}/${due.month}/${due.year}'),
        trailing: IconButton(
          tooltip: 'รายละเอียดเส้นทาง',
          icon: const Icon(Icons.info_outline),
          onPressed: onDetail,
        ),
      ),
    );
  }
}

class CorporateReportsScreen extends StatelessWidget {
  const CorporateReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายงานการเรียน')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ReportMetric(title: 'อัตราเรียนจบ', value: '68%', detail: 'เพิ่มขึ้น 6% จากเดือนก่อน'),
          _ReportMetric(title: 'ผู้เรียนที่ active', value: '386', detail: 'จากพนักงานที่ลงทะเบียน 500 คน'),
          _ReportMetric(title: 'ชั่วโมงเรียนเดือนนี้', value: '1,240 ชม.', detail: 'ข้อมูลตัวอย่างสำหรับ MVP'),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({required this.title, required this.value, required this.detail});
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.cardBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)), const SizedBox(height: 5), Text(value, style: AppTypography.h1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(detail, style: AppTypography.caption)]),
  );
}

bool _validEmail(String input) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input.trim());