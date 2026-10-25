import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String query = '';
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final rows =
          await ref.read(apiClientProvider).getAdminUsers(query: query);
      if (mounted) {
        setState(() {
          users = rows.cast<Map<String, dynamic>>();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  Future<void> _setStatus(Map<String, dynamic> user, bool active) async {
    try {
      final id = (user['id'] as num).toInt();
      final updated = active
          ? await ref
              .read(apiClientProvider)
              .updateAdminUser(id, {'status': 'active'})
          : await ref
              .read(apiClientProvider)
              .suspendAdminUser(id, reason: 'Suspended by administrator');
      setState(() {
        user.addAll(updated.isEmpty
            ? {'status': active ? 'active' : 'suspended'}
            : updated);
      });
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _changeRole(Map<String, dynamic> user) async {
    const roles = <String, String>{
      'LEARNER': 'Learner',
      'INSTRUCTOR': 'Instructor',
      'CORP_ADMIN': 'Corporate Admin',
      'CORP_MANAGER': 'Corporate Manager',
      'EMPLOYER': 'Employer',
      'ADMIN': 'Admin',
    };
    final selected = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text('กำหนดบทบาท'),
              children: [
                for (final entry in roles.entries)
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, entry.key),
                      child: Text(entry.value))
              ],
            ));
    if (selected == null) return;
    try {
      final updated = await ref
          .read(apiClientProvider)
          .updateAdminUser((user['id'] as num).toInt(), {'role': selected});
      if (mounted) setState(() => user.addAll(updated));
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ดำเนินการไม่สำเร็จ: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการผู้ใช้')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
            onChanged: (value) {
              query = value;
              _load();
            },
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ค้นหาชื่อหรืออีเมล')),
        const SizedBox(height: 12),
        Text('${users.length} บัญชี',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        if (loading)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator())),
        if (error != null) _ErrorPanel(message: error!, onRetry: _load),
        for (final user in users)
          _Panel(
              child: ListTile(
            leading: CircleAvatar(
                child: Text((user['first_name'] as String? ??
                        user['email'] as String? ??
                        '?')
                    .characters
                    .first)),
            title: Text('${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
                .trim()),
            subtitle: Text('${user['email']} · ${user['role']}'),
            trailing: Switch(
                value: user['status'] == 'active',
                onChanged: loading ? null : (value) => _setStatus(user, value)),
            onTap: () => _changeRole(user),
          )),
        if (!loading && error == null && users.isEmpty)
          const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('ไม่พบผู้ใช้'))),
        const SizedBox(height: 8),
        const Text('แตะบัญชีเพื่อเปลี่ยนบทบาท · ปิดสวิตช์เพื่อระงับบัญชี',
            style: AppTypography.caption),
      ]),
    );
  }
}

class AdminModerationScreen extends ConsumerStatefulWidget {
  const AdminModerationScreen({super.key});
  @override
  ConsumerState<AdminModerationScreen> createState() =>
      _AdminModerationScreenState();
}

class _AdminModerationScreenState extends ConsumerState<AdminModerationScreen> {
  List<Map<String, dynamic>> courses = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).getAdminPendingCourses();
      if (mounted) {
        setState(() {
          courses = rows.cast<Map<String, dynamic>>();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  Future<void> _review(Map<String, dynamic> course,
      {required bool approve}) async {
    String reason = '';
    if (!approve) {
      final reasonController = TextEditingController();
      final confirmed = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('ส่งกลับเพื่อแก้ไข'),
                content: TextField(
                    controller: reasonController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'เหตุผล')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ยกเลิก')),
                  FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, reasonController.text.trim()),
                      child: const Text('ยืนยัน')),
                ],
              ));
      reasonController.dispose();
      if (confirmed == null || confirmed.isEmpty) return;
      reason = confirmed;
    }
    try {
      final api = ref.read(apiClientProvider);
      final id = (course['id'] as num).toInt();
      if (approve) {
        await api.approveCourse(id);
      } else {
        await api.rejectCourse(id, reason: reason);
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ดำเนินการไม่สำเร็จ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ตรวจสอบคอร์ส')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _ErrorPanel(message: error!, onRetry: _load)
                : courses.isEmpty
                    ? const Center(child: Text('ไม่มีคอร์สรอตรวจสอบ'))
                    : ListView(padding: const EdgeInsets.all(16), children: [
                        Text('${courses.length} คอร์สรอตรวจสอบ',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 10),
                        for (final course in courses)
                          _Panel(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(course['title'] as String? ?? '',
                                            style: AppTypography.h2),
                                        const SizedBox(height: 4),
                                        Text(
                                            'ผู้สอน: ${course['instructor_name'] ?? course['instructor'] ?? '-'}',
                                            style: AppTypography.caption),
                                        const SizedBox(height: 14),
                                        Row(children: [
                                          Expanded(
                                              child: OutlinedButton(
                                                  onPressed: () => _review(
                                                      course,
                                                      approve: false),
                                                  child: const Text(
                                                      'ส่งกลับแก้ไข'))),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: FilledButton.icon(
                                                  onPressed: () => _review(
                                                      course,
                                                      approve: true),
                                                  icon: const Icon(Icons.check),
                                                  label: const Text('อนุมัติ')))
                                        ]),
                                      ]))),
                      ]),
      );
}

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});
  @override
  ConsumerState<AdminPaymentsScreen> createState() =>
      _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  List<Map<String, dynamic>> payments = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).getAdminPayments();
      if (mounted) {
        setState(() {
          payments = rows.cast<Map<String, dynamic>>();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  Future<void> _refund(Map<String, dynamic> payment) async {
    final id = (payment['id'] as num).toInt();
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('ยืนยันคืนเงิน'),
              content: Text(
                  'คืนเงิน ${payment['amount'] ?? ''} ให้ ${payment['customer_name'] ?? payment['customer'] ?? 'ลูกค้า'}?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('ยกเลิก')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('คืนเงิน'))
              ],
            ));
    if (confirm != true) return;
    try {
      await ref
          .read(apiClientProvider)
          .refundAdminPayment(id, reason: 'Refunded by administrator');
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('คืนเงินไม่สำเร็จ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('รายการชำระเงิน')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _ErrorPanel(message: error!, onRetry: _load)
                : payments.isEmpty
                    ? const Center(child: Text('ไม่มีรายการชำระเงิน'))
                    : ListView(padding: const EdgeInsets.all(16), children: [
                        _Panel(
                            child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Text(
                                    'รายการชำระเงิน ${payments.length} รายการ',
                                    style: AppTypography.h2))),
                        const SizedBox(height: 12),
                        for (final payment in payments)
                          _Panel(
                              child: ListTile(
                            leading: const CircleAvatar(
                                child: Icon(Icons.receipt_long_outlined)),
                            title: Text(
                                '${payment['reference'] ?? payment['id'] ?? 'รายการ'}'),
                            subtitle: Text(
                                '${payment['customer_name'] ?? payment['customer'] ?? payment['user_email'] ?? ''} · ฿${payment['amount'] ?? 0} · ${payment['status'] ?? ''}'),
                            trailing: payment['status'] == 'refunded'
                                ? const Chip(label: Text('คืนเงินแล้ว'))
                                : TextButton(
                                    onPressed: () => _refund(payment),
                                    child: const Text('คืนเงิน')),
                          )),
                      ]),
      );
}

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool maintenance = false;
  bool registration = true;
  bool moderation = true;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ตั้งค่าระบบ')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('การตั้งค่าทั่วไป', style: AppTypography.h2),
          const SizedBox(height: 10),
          _Panel(
              child: Column(children: [
            SwitchListTile(
                title: const Text('โหมดบำรุงรักษา'),
                subtitle: const Text('จำกัดการเข้าใช้งานชั่วคราว'),
                value: maintenance,
                onChanged: (v) => setState(() => maintenance = v)),
            const Divider(height: 1),
            SwitchListTile(
                title: const Text('เปิดรับสมาชิกใหม่'),
                value: registration,
                onChanged: (v) => setState(() => registration = v)),
            const Divider(height: 1),
            SwitchListTile(
                title: const Text('ตรวจสอบคอร์สก่อนเผยแพร่'),
                value: moderation,
                onChanged: (v) => setState(() => moderation = v)),
          ])),
          const SizedBox(height: 8),
          const Text('การเปลี่ยนแปลงมีผลในตัวอย่างนี้เท่านั้น',
              style: AppTypography.caption),
        ]),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder)),
      child: child);
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined),
            const SizedBox(height: 8),
            Text('โหลดข้อมูลไม่สำเร็จ: $message', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองอีกครั้ง'))
          ])));
}
