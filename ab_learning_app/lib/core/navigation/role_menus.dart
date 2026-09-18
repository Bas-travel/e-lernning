import 'package:flutter/material.dart';

/// Every role the backend knows about (must match the `roles.code` values
/// seeded in `db/init/02_seed.sql` and the JWT `role` claim `pkg/jwtx`
/// issues) plus GUEST, which never has a token at all.
enum AppRole { guest, learner, instructor, corpAdmin, corpManager, employer, admin }

AppRole roleFromString(String value) {
  switch (value) {
    case 'LEARNER':
      return AppRole.learner;
    case 'INSTRUCTOR':
      return AppRole.instructor;
    case 'CORP_ADMIN':
      return AppRole.corpAdmin;
    case 'CORP_MANAGER':
      return AppRole.corpManager;
    case 'EMPLOYER':
      return AppRole.employer;
    case 'ADMIN':
      return AppRole.admin;
    default:
      return AppRole.guest;
  }
}

/// Where a freshly-logged-in user of this role should land, and which
/// route prefix `app_router.dart`'s guard treats as "belongs to this role".
String homeRouteForRole(AppRole role) {
  switch (role) {
    case AppRole.learner:
      return '/home';
    case AppRole.instructor:
      return '/instructor';
    case AppRole.corpAdmin:
    case AppRole.corpManager:
      return '/corporate';
    case AppRole.employer:
      return '/employer';
    case AppRole.admin:
      return '/admin';
    case AppRole.guest:
      return '/login';
  }
}

/// One entry in a role's navigation menu. [route] is null for items that
/// are visible but not wired to a screen yet (rendered disabled, honest
/// about scope rather than a dead link) — mirrors the `toast('เร็วๆ นี้')`
/// pattern used for the same items in `02-hifi-mockups.html`.
class RoleNavItem {
  const RoleNavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String? route;
}

/// Mobile: 5-item bottom nav, matching §02 of the blueprint overview
/// exactly. Desktop: full 11-item sidebar, matching LEARNER_SIDEBAR in
/// 02-hifi-mockups.html.
const List<RoleNavItem> learnerBottomTabs = <RoleNavItem>[
  RoleNavItem('Home', Icons.home_rounded, '/home'),
  RoleNavItem('Explore', Icons.search_rounded, '/explore'),
  RoleNavItem('Learn', Icons.school_rounded, '/home'),
  RoleNavItem('Community', Icons.forum_rounded, '/home'),
  RoleNavItem('Profile', Icons.person_rounded, '/home'),
];

const List<RoleNavItem> learnerSidebar = <RoleNavItem>[
  RoleNavItem('Home', Icons.home_rounded, '/home'),
  RoleNavItem('Explore', Icons.search_rounded, '/explore'),
  RoleNavItem('My Learning', Icons.menu_book_rounded, null),
  RoleNavItem('Live', Icons.live_tv_rounded, null),
  RoleNavItem('Community', Icons.forum_rounded, null),
  RoleNavItem('AI Tutor', Icons.smart_toy_rounded, null),
  RoleNavItem('Career', Icons.trending_up_rounded, null),
  RoleNavItem('Portfolio', Icons.badge_rounded, null),
  RoleNavItem('Jobs', Icons.work_rounded, null),
  RoleNavItem('Wallet', Icons.account_balance_wallet_rounded, null),
  RoleNavItem('Settings', Icons.settings_rounded, null),
];

/// Business roles (Instructor / Corp / Employer / Admin) use the SAME
/// sidebar on desktop and a horizontal chip strip on mobile — matching
/// `roleChipNavHtml()` / `sidebarHtml()` in 02-hifi-mockups.html exactly,
/// just as Flutter widgets instead of generated HTML strings.
const List<RoleNavItem> instructorMenu = <RoleNavItem>[
  RoleNavItem('Dashboard', Icons.dashboard_rounded, '/instructor'),
  RoleNavItem('My Courses', Icons.video_library_rounded, null),
  RoleNavItem('Course Builder', Icons.build_rounded, null),
  RoleNavItem('Revenue', Icons.payments_rounded, null),
  RoleNavItem('Settings', Icons.settings_rounded, null),
];

const List<RoleNavItem> corporateMenu = <RoleNavItem>[
  RoleNavItem('Dashboard', Icons.dashboard_rounded, '/corporate'),
  RoleNavItem('Employees', Icons.groups_rounded, null),
  RoleNavItem('Learning Paths', Icons.route_rounded, null),
  RoleNavItem('Reports', Icons.bar_chart_rounded, null),
];

const List<RoleNavItem> employerMenu = <RoleNavItem>[
  RoleNavItem('Dashboard', Icons.dashboard_rounded, '/employer'),
  RoleNavItem('Jobs', Icons.work_rounded, null),
  RoleNavItem('Applications', Icons.description_rounded, null),
  RoleNavItem('Talent Search', Icons.person_search_rounded, null),
];

const List<RoleNavItem> adminMenu = <RoleNavItem>[
  RoleNavItem('Dashboard', Icons.dashboard_rounded, '/admin'),
  RoleNavItem('Users', Icons.people_alt_rounded, null),
  RoleNavItem('Course Moderation', Icons.fact_check_rounded, null),
  RoleNavItem('Payments', Icons.credit_card_rounded, null),
  RoleNavItem('Settings', Icons.settings_rounded, null),
];

List<RoleNavItem> sidebarFor(AppRole role) {
  switch (role) {
    case AppRole.learner:
      return learnerSidebar;
    case AppRole.instructor:
      return instructorMenu;
    case AppRole.corpAdmin:
    case AppRole.corpManager:
      return corporateMenu;
    case AppRole.employer:
      return employerMenu;
    case AppRole.admin:
      return adminMenu;
    case AppRole.guest:
      return const <RoleNavItem>[];
  }
}

String labelFor(AppRole role) {
  switch (role) {
    case AppRole.learner:
      return 'Learner';
    case AppRole.instructor:
      return 'Instructor';
    case AppRole.corpAdmin:
      return 'Corporate Admin';
    case AppRole.corpManager:
      return 'Corporate Manager';
    case AppRole.employer:
      return 'Employer';
    case AppRole.admin:
      return 'Admin';
    case AppRole.guest:
      return 'Guest';
  }
}
