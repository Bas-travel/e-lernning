import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';

/// Bell icon that opens the inbox and shows how many notifications are
/// unread. A failed or offline lookup simply shows no badge.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final page =
          await AppDependencies.notificationsRepository.list(unreadOnly: true);
      if (mounted) setState(() => _unread = page.unread);
    } on Object catch (e) {
      debugPrint('unread count unavailable: $e');
    }
  }

  Future<void> _open() async {
    await context.push<void>('/notifications');
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _unread > 0 ? 'การแจ้งเตือน $_unread ใหม่' : 'การแจ้งเตือน',
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none,
                size: 18,
                color: AppColors.textSecondary,
              ),
              if (_unread > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _unread > 9 ? '9+' : '$_unread',
                      style: const TextStyle(
                        fontSize: 9,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
