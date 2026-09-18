import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/role_menus.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

/// The single piece of chrome every authenticated screen is wrapped in.
/// Picks bottom-nav-vs-sidebar (learner) or chip-nav-vs-sidebar (business
/// roles) based on [role] and the current breakpoint — the direct Flutter
/// equivalent of the `render()`-time chrome wrapping in
/// `02-hifi-mockups.html`'s navigation engine. Screens don't each build
/// their own nav; they're just wrapped in this.
class RoleScaffold extends StatelessWidget {
  const RoleScaffold({
    required this.role,
    required this.activeRoute,
    required this.title,
    required this.child,
    super.key,
  });

  final AppRole role;
  final String activeRoute;
  final String title;
  final Widget child;

  void _handleTap(BuildContext context, RoleNavItem item) {
    if (item.route == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('${item.label} — เร็วๆ นี้'),
          duration: const Duration(seconds: 1),
        ));
      return;
    }
    if (item.route != activeRoute) context.go(item.route!);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLearner = role == AppRole.learner;
    final List<RoleNavItem> items = isLearner ? learnerBottomTabs : sidebarFor(role);
    final List<RoleNavItem> sidebarItems = sidebarFor(role);

    return ResponsiveBuilder(
      mobile: (_) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(title)),
        body: isLearner
            ? child
            : Column(
                children: <Widget>[
                  _ChipNav(items: sidebarItems, activeRoute: activeRoute, onTap: (i) => _handleTap(context, i)),
                  Expanded(child: child),
                ],
              ),
        bottomNavigationBar: isLearner
            ? _BottomNav(items: items, activeRoute: activeRoute, onTap: (i) => _handleTap(context, i))
            : null,
      ),
      desktop: (_) => Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: <Widget>[
            _Sidebar(role: role, items: sidebarItems, activeRoute: activeRoute, onTap: (i) => _handleTap(context, i)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Text(title, style: AppTypography.h1),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.items, required this.activeRoute, required this.onTap});
  final List<RoleNavItem> items;
  final String activeRoute;
  final ValueChanged<RoleNavItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((RoleNavItem item) {
            final bool active = item.route == activeRoute;
            final Color color = active ? AppColors.primary : AppColors.textSecondary;
            return InkWell(
              onTap: () => onTap(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(item.icon, size: 22, color: color),
                    const SizedBox(height: 2),
                    Text(item.label,
                        style: TextStyle(fontSize: 10, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ChipNav extends StatelessWidget {
  const _ChipNav({required this.items, required this.activeRoute, required this.onTap});
  final List<RoleNavItem> items;
  final String activeRoute;
  final ValueChanged<RoleNavItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((RoleNavItem item) {
            final bool active = item.route == activeRoute;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(item.label, style: const TextStyle(fontSize: 12.5)),
                avatar: Icon(item.icon, size: 15, color: active ? Colors.white : AppColors.textSecondary),
                selected: active,
                onSelected: (_) => onTap(item),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: active ? Colors.white : AppColors.textPrimary),
                backgroundColor: AppColors.background,
                side: BorderSide(color: active ? AppColors.primary : AppColors.border),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.role, required this.items, required this.activeRoute, required this.onTap});
  final AppRole role;
  final List<RoleNavItem> items;
  final String activeRoute;
  final ValueChanged<RoleNavItem> onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLearner = role == AppRole.learner;
    return Container(
      width: isLearner ? 240 : 240,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('AB LEARNING',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(labelFor(role), style: AppTypography.micro),
          ),
          const SizedBox(height: 14),
          for (final RoleNavItem item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Material(
                color: item.route == activeRoute ? const Color(0xFFEEF2FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onTap(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    child: Row(
                      children: <Widget>[
                        Icon(item.icon,
                            size: 18,
                            color: item.route == activeRoute ? AppColors.primary : AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: item.route == activeRoute ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: item.route == activeRoute ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
