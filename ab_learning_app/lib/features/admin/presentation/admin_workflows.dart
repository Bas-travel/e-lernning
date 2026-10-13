import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';

/// In-memory fixtures keep the admin workflows interactive until API wiring.
class AdminDemoStore {
  static final users = <AdminUser>[
    AdminUser(name: 'Krit Srisuk', email: 'krit@ablearning.co', role: 'Instructor'),
    AdminUser(name: 'Pimchanok Sae-Tang', email: 'pim@ablearning.co', role: 'Learner'),
    AdminUser(name: 'Narin Pongsak', email: 'narin@abc-tech.co', role: 'Corporate Admin'),
  ];
  static final courses = <AdminCourse>[
    AdminCourse(title: 'Go Backend Essentials', instructor: 'Krit Srisuk'),
    AdminCourse(title: 'Data Literacy for Teams', instructor: 'Narin Pongsak'),
  ];
  static final payments = <AdminPayment>[
    AdminPayment(id: 'TX-2026-0912', customer: 'Pimchanok Sae-Tang', amount: 2490),
    AdminPayment(id: 'TX-2026-0911', customer: 'Anan Wong', amount: 1590),
  ];
}

class AdminUser {
  AdminUser({required this.name, required this.email, required this.role, this.active = true});
  final String name;
  final String email;
  String role;
  bool active;
}

class AdminCourse {
  AdminCourse({required this.title, required this.instructor});
  final String title;
  final String instructor;
}

class AdminPayment {
  AdminPayment({required this.id, required this.customer, required this.amount, this.refunded = false});
  final String id;
  final String customer;
  final int amount;
  bool refunded;
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final users = AdminDemoStore.users.where((u) => '${u.name} ${u.email}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการผู้ใช้')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(onChanged: (value) => setState(() => query = value), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ค้นหาชื่อหรืออีเมล')),
        const SizedBox(height: 12),
        Text('${users.length} บัญชี', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        for (final user in users) _Panel(child: ListTile(
          leading: CircleAvatar(child: Text(user.name.characters.first)),
          title: Text(user.name), subtitle: Text('${user.email} · ${user.role}'),
          trailing: Switch(value: user.active, onChanged: (value) => setState(() => user.active = value)),
          onTap: () async {
            final role = await showDialog<String>(context: context, builder: (context) => SimpleDialog(title: const Text('กำหนดบทบาท'), children: [for (final item in ['Learner', 'Instructor', 'Corporate Admin', 'Corporate Manager', 'Employer', 'Admin']) SimpleDialogOption(onPressed: () => Navigator.pop(context, item), child: Text(item))]));
            if (role != null && mounted) setState(() => user.role = role);
          },
        )),
        if (users.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('ไม่พบผู้ใช้'))),
        const SizedBox(height: 8),
        const Text('แตะบัญชีเพื่อเปลี่ยนบทบาท · ปิดสวิตช์เพื่อระงับบัญชี', style: AppTypography.caption),
      ]),
    );
  }
}

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});
  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  Future<void> _review(AdminCourse course, {required bool approve}) async {
    if (!approve) {
      final reason = TextEditingController();
      final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('ส่งกลับเพื่อแก้ไข'), content: TextField(controller: reason, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'เหตุผล')),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')), FilledButton(onPressed: () => Navigator.pop(context, reason.text.trim().isNotEmpty), child: const Text('ยืนยัน'))]));
      reason.dispose();
      if (confirmed != true) return;
    }
    if (!mounted) return;
    setState(() => AdminDemoStore.courses.remove(course));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? 'อนุมัติคอร์สแล้ว' : 'ส่งคอร์สกลับให้ผู้สอนแล้ว')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ตรวจสอบคอร์ส')),
    body: AdminDemoStore.courses.isEmpty
      ? const Center(child: Text('ไม่มีคอร์สรอตรวจสอบ'))
      : ListView(padding: const EdgeInsets.all(16), children: [
        Text('${AdminDemoStore.courses.length} คอร์สรอตรวจสอบ', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        for (final course in AdminDemoStore.courses.toList()) _Panel(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course.title, style: AppTypography.h2), const SizedBox(height: 4), Text('ผู้สอน: ${course.instructor}', style: AppTypography.caption),
          const SizedBox(height: 14), Row(children: [Expanded(child: OutlinedButton(onPressed: () => _review(course, approve: false), child: const Text('ส่งกลับแก้ไข'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: () => _review(course, approve: true), icon: const Icon(Icons.check), label: const Text('อนุมัติ')))]),
        ]))),
      ]),
  );
}

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});
  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('รายการชำระเงิน')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _Panel(child: Padding(padding: const EdgeInsets.all(18), child: Text('ยอดชำระสำเร็จ ฿${AdminDemoStore.payments.where((p) => !p.refunded).fold<int>(0, (sum, p) => sum + p.amount)}', style: AppTypography.h2))),
      const SizedBox(height: 12),
      for (final payment in AdminDemoStore.payments) _Panel(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
        title: Text(payment.id), subtitle: Text('${payment.customer} · ฿${payment.amount}'),
        trailing: payment.refunded ? const Chip(label: Text('คืนเงินแล้ว')) : TextButton(onPressed: () async {
          final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('ยืนยันคืนเงิน'), content: Text('คืนเงิน ฿${payment.amount} ให้ ${payment.customer}?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('คืนเงิน'))]));
          if (confirm == true && mounted) setState(() => payment.refunded = true);
        }, child: const Text('คืนเงิน')),
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
      const Text('การตั้งค่าทั่วไป', style: AppTypography.h2), const SizedBox(height: 10),
      _Panel(child: Column(children: [
        SwitchListTile(title: const Text('โหมดบำรุงรักษา'), subtitle: const Text('จำกัดการเข้าใช้งานชั่วคราว'), value: maintenance, onChanged: (v) => setState(() => maintenance = v)),
        const Divider(height: 1),
        SwitchListTile(title: const Text('เปิดรับสมาชิกใหม่'), value: registration, onChanged: (v) => setState(() => registration = v)),
        const Divider(height: 1),
        SwitchListTile(title: const Text('ตรวจสอบคอร์สก่อนเผยแพร่'), value: moderation, onChanged: (v) => setState(() => moderation = v)),
      ])),
      const SizedBox(height: 8), const Text('การเปลี่ยนแปลงมีผลในตัวอย่างนี้เท่านั้น', style: AppTypography.caption),
    ]),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.cardBorder)), child: child);
}
