import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import '../../../data/mock/current_user.dart';
import '../data/notifications_repository.dart';

/// Inbox for every role. States: loading, error (retry), empty, list.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationPage? _page;
  bool _loading = true;
  bool _failed = false;

  NotificationsRepository get _repo => AppDependencies.notificationsRepository;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await _repo.list();
      if (!mounted) return;
      setState(() {
        _page = page;
        _loading = false;
      });
    } on Object catch (e) {
      debugPrint('notifications failed to load: $e');
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _open(AppNotification n) async {
    if (n.isRead) return;
    final ok = await _repo.markRead(n.id);
    if (!mounted || !ok) return;
    final page = _page;
    if (page == null) return;
    setState(() {
      _page = NotificationPage(
        items: [for (final i in page.items) i.id == n.id ? i.asRead() : i],
        unread: page.unread > 0 ? page.unread - 1 : 0,
      );
    });
  }

  Future<void> _readAll() async {
    final ok = await _repo.markAllRead();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ทำเครื่องหมายว่าอ่านแล้วไม่สำเร็จ')),
      );
      return;
    }
    final page = _page;
    if (page == null) return;
    setState(() {
      _page = NotificationPage(
        items: [for (final i in page.items) i.asRead()],
        unread: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
    return SubPageScaffold(
      title: 'การแจ้งเตือน',
      fallbackRoute: CurrentUser.homeRouteFor(CurrentUser.role),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_failed)
          _Message(
            text: 'โหลดการแจ้งเตือนไม่สำเร็จ',
            action: TextButton(onPressed: _load, child: const Text('ลองใหม่')),
          )
        else if (page == null || page.items.isEmpty)
          const _Message(
            text: 'ยังไม่มีการแจ้งเตือน\n'
                'เมื่อมีข่าวสารเกี่ยวกับคอร์สของคุณ จะแสดงที่นี่',
          )
        else ...[
          if (page.unread > 0)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _readAll,
                child: Text('อ่านทั้งหมด (${page.unread})'),
              ),
            ),
          for (final n in page.items) _Tile(n: n, onTap: () => _open(n)),
        ],
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.notifications_none,
              size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.base(13, color: AppColors.textSecondary),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.n, required this.onTap});

  final AppNotification n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        n.type == 'order_failed' ? Icons.error_outline : Icons.notifications,
        color: n.isRead ? AppColors.textSecondary : AppColors.primary,
      ),
      title: Text(
        n.title,
        style: AppTypography.base(
          13.5,
          weight: n.isRead ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: n.body.isEmpty ? null : Text(n.body),
      trailing: n.isRead
          ? null
          : const Icon(Icons.circle, size: 8, color: AppColors.primary),
    );
  }
}
