import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Maps shell navigation (bottom tabs / desktop sidebar) to routes.
/// Targets without a screen yet are ignored (see TODO list in the PR).
class NavTargets {
  static const _tabRoutes = <int, String>{
    0: '/home',
    1: '/explore',
    2: '/learn',
    4: '/profile',
  };
  static const _sidebarRoutes = <String, String>{
    'home': '/home',
    'explore': '/explore',
    'learn': '/learn',
  };

  static void onTab(BuildContext context, int index) {
    final route = _tabRoutes[index];
    if (route != null) context.go(route);
  }

  static void onSidebar(BuildContext context, String key) {
    final route = _sidebarRoutes[key];
    if (route != null) context.go(route);
  }
}
