import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/current_user.dart';
import '../../../core/navigation/role_menus.dart';

class CorporateEmployee {
  CorporateEmployee(
      {required this.name,
      required this.email,
      required this.department,
      this.active = true});
  final String name;
  final String email;
  final String department;
  bool active;
}

class LearningAssignment {
  LearningAssignment(
      {required this.title, required this.department, required this.dueDate});
  final String title;
  final String department;
  final DateTime dueDate;
}

class CorporateDemoStore {
  static final employees = <CorporateEmployee>[
    CorporateEmployee(
        name: 'Narin Pongsak',
        email: 'narin@abc-tech.co',
        department: 'Engineering'),
    CorporateEmployee(
        name: 'Pimchanok Sae-Tang',
        email: 'pimchanok@abc-tech.co',
        department: 'Design'),
    CorporateEmployee(
        name: 'Thanawat K.',
        email: 'thanawat@abc-tech.co',
        department: 'Sales'),
  ];
  static final learningPaths = <LearningAssignment>[
    LearningAssignment(
        title: 'Cloud Engineering Foundations',
        department: 'Engineering',
        dueDate: DateTime.now().add(const Duration(days: 30))),
    LearningAssignment(
        title: 'Data Literacy for Teams',
        department: 'All departments',
        dueDate: DateTime.now().add(const Duration(days: 45))),
  ];
}

class CorporateEmployeesScreen extends ConsumerStatefulWidget {
  const CorporateEmployeesScreen({super.key});

  @override
  ConsumerState<CorporateEmployeesScreen> createState() =>
      _CorporateEmployeesScreenState();
}

class _CorporateEmployeesScreenState
    extends ConsumerState<CorporateEmployeesScreen> {
  final _searchController = TextEditingController();
  String _department = 'ทั้งหมด';
  static const _departments = ['ทั้งหมด', 'Engineering', 'Design', 'Sales'];
  List<Map<String, dynamic>> _employees = [];
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
      final rows = await ref.read(apiClientProvider).getCorporateEmployees(
            query: _searchController.text.trim(),
            department: _department == 'ทั้งหมด' ? null : _department,
          );
      if (mounted) {
        setState(() {
          _employees = rows.cast<Map<String, dynamic>>();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addEmployee() async {
    final email = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    String department = 'Engineering';
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('เพิ่มพนักงาน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'อีเมลบริษัท')),
              DropdownButtonFormField<String>(
                initialValue: department,
                decoration: const InputDecoration(labelText: 'แผนก'),
                items: _departments
                    .skip(1)
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => department = value ?? department),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () {
                if (!_validEmail(email.text)) return;
                Navigator.pop(dialogContext,
                    {'email': email.text.trim(), 'department': department});
              },
              child: const Text('เพิ่มพนักงาน'),
            ),
          ],
        ),
      ),
    );
    email.dispose();
    if (result == null || !mounted) return;
    try {
      await ref
          .read(apiClientProvider)
          .addCorporateEmployee({...result, 'role_in_org': 'employee'});
      await _load();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
            SnackBar(content: Text('เพิ่มพนักงานไม่สำเร็จ: $error')));
      }
    }
  }

  bool get _canManageEmployees => CurrentUser.role == AppRole.corpAdmin;

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('พนักงาน')),
      floatingActionButton: _canManageEmployees
          ? FloatingActionButton.extended(
              onPressed: _addEmployee,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('เพิ่มพนักงาน'))
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _load(),
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'ค้นหาชื่อหรืออีเมล'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _departments
                  .map((department) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(department),
                            selected: _department == department,
                            onSelected: (_) {
                              setState(() => _department = department);
                              _load();
                            }),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
              '${_employees.length} คน · สิทธิ์ ${_canManageEmployees ? 'จัดการ' : 'ดูอย่างเดียว'}',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
          if (_error != null)
            Center(
                child: Column(children: [
              Text('โหลดพนักงานไม่สำเร็จ: $_error'),
              TextButton(onPressed: _load, child: const Text('ลองอีกครั้ง'))
            ])),
          if (!_loading && _error == null && _employees.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24), child: Text('ไม่พบพนักงาน'))),
          for (final employee in _employees)
            _EmployeeTile(
                employee: employee,
                canManage: _canManageEmployees,
                onChanged: (active) async {
                  try {
                    await ref.read(apiClientProvider).updateCorporateEmployee(
                        (employee['id'] as num).toInt(),
                        {'status': active ? 'active' : 'inactive'});
                    await _load();
                  } catch (error) {
                    if (mounted) {
                      messenger.showSnackBar(SnackBar(
                          content: Text('เปลี่ยนสถานะไม่สำเร็จ: $error')));
                    }
                  }
                }),
        ],
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile(
      {required this.employee,
      required this.canManage,
      required this.onChanged});
  final Map<String, dynamic> employee;
  final bool canManage;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder)),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
                (employee['name'] ?? employee['email'] ?? '?')
                    .toString()
                    .characters
                    .first,
                style: const TextStyle(color: AppColors.primary))),
        title: Text('${employee['name'] ?? 'ผู้เรียน'}',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${employee['email'] ?? ''} · ${employee['department'] ?? 'ไม่ระบุแผนก'}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        trailing: canManage
            ? Switch(
                value: employee['status'] == 'active', onChanged: onChanged)
            : Text('${employee['status'] ?? 'active'}',
                style: AppTypography.micro.copyWith(
                    color: employee['status'] == 'active'
                        ? AppColors.success
                        : AppColors.warning)),
      ),
    );
  }
}

class CorporateLearningPathsScreen extends ConsumerStatefulWidget {
  const CorporateLearningPathsScreen({super.key});

  @override
  ConsumerState<CorporateLearningPathsScreen> createState() =>
      _CorporateLearningPathsScreenState();
}

class _CorporateLearningPathsScreenState
    extends ConsumerState<CorporateLearningPathsScreen> {
  List<Map<String, dynamic>> _paths = [];
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
      final rows =
          await ref.read(apiClientProvider).getCorporateLearningPaths();
      if (mounted) {
        setState(() {
          _paths = rows.cast<Map<String, dynamic>>();
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

  Future<void> _createPath() async {
    final messenger = ScaffoldMessenger.of(context);
    List<Map<String, dynamic>> availableCourses;
    try {
      availableCourses = (await ref.read(apiClientProvider).getCourses())
          .cast<Map<String, dynamic>>();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
            SnackBar(content: Text('โหลดรายการคอร์สไม่สำเร็จ: $error')));
      }
      return;
    }
    if (!mounted) return;
    if (availableCourses.isEmpty) {
      messenger.showSnackBar(const SnackBar(
          content: Text('ยังไม่มีคอร์สที่เผยแพร่ให้เพิ่มในเส้นทาง')));
      return;
    }
    final title = TextEditingController();
    int? courseId = (availableCourses.first['id'] as num).toInt();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('สร้าง Learning Path'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: title,
                  decoration:
                      const InputDecoration(labelText: 'ชื่อเส้นทางการเรียน')),
              DropdownButtonFormField<int>(
                initialValue: courseId,
                decoration: const InputDecoration(labelText: 'คอร์สในเส้นทาง'),
                items: availableCourses
                    .map((course) => DropdownMenuItem(
                        value: (course['id'] as num).toInt(),
                        child: Text('${course['title'] ?? 'คอร์ส'}')))
                    .toList(),
                onChanged: (value) => setDialogState(() => courseId = value),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) return;
                if (courseId == null) return;
                Navigator.pop(dialogContext, {
                  'name': title.text.trim(),
                  'goal': '',
                  'course_ids': [courseId]
                });
              },
              child: const Text('สร้างเส้นทาง'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    if (result == null || !mounted) return;
    try {
      await ref.read(apiClientProvider).createCorporateLearningPath(result);
      await _load();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
            SnackBar(content: Text('สร้างเส้นทางไม่สำเร็จ: $error')));
      }
    }
  }

  void _showPathDetail(Map<String, dynamic> path) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${path['name'] ?? 'Learning Path'}'),
        content: Text(
          '${path['goal'] ?? ''}\n'
          'คอร์สในเส้นทาง: ${(path['courses'] as List<dynamic>? ?? const []).length}',
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
      floatingActionButton: CurrentUser.role == AppRole.corpAdmin
          ? FloatingActionButton.extended(
              onPressed: _createPath,
              icon: const Icon(Icons.add),
              label: const Text('สร้างเส้นทาง'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('เส้นทางการเรียนขององค์กร', style: AppTypography.h2),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
          if (_error != null)
            Center(
                child: Column(children: [
              Text('โหลดเส้นทางไม่สำเร็จ: $_error'),
              TextButton(onPressed: _load, child: const Text('ลองอีกครั้ง'))
            ])),
          if (!_loading && _error == null && _paths.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('ยังไม่มี Learning Path'))),
          for (final path in _paths)
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
  final Map<String, dynamic> path;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final courses = path['courses'] as List<dynamic>? ?? const [];
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
          '${path['name'] ?? 'Learning Path'}',
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${courses.length} คอร์ส · ${path['goal'] ?? ''}'),
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
          _ReportMetric(
              title: 'อัตราเรียนจบ',
              value: '68%',
              detail: 'เพิ่มขึ้น 6% จากเดือนก่อน'),
          _ReportMetric(
              title: 'ผู้เรียนที่ active',
              value: '386',
              detail: 'จากพนักงานที่ลงทะเบียน 500 คน'),
          _ReportMetric(
              title: 'ชั่วโมงเรียนเดือนนี้',
              value: '1,240 ชม.',
              detail: 'ข้อมูลตัวอย่างสำหรับ MVP'),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric(
      {required this.title, required this.value, required this.detail});
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 5),
          Text(value,
              style: AppTypography.h1.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(detail, style: AppTypography.caption)
        ]),
      );
}

bool _validEmail(String input) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input.trim());
