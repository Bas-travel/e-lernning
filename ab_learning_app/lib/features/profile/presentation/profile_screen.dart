import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/router/nav_targets.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/responsive.dart';
import '../../auth/domain/auth_models.dart';

/// Demo values from the mockup, used until the API provides them.
/// TODO(api): `GET /api/v1/me` (profile) and `GET /api/v1/gamification` (stats).
const _fallbackName = 'Anan Suksawat';
const _fallbackEmail = 'learner@ablearning.com';
const _learningProgress = 0.68;
const _stats = <({String label, String value})>[
  (label: 'Courses', value: '6'),
  (label: 'Certificates', value: '3'),
  (label: 'Streak', value: '18 🔥'),
];

const _menuItems = [
  'Edit Profile',
  'My Courses',
  'Wallet',
  'Certificates',
  'Portfolio',
  'Settings',
  'Help Center',
];
const _desktopTabs = [
  'Overview',
  'My Courses',
  'Wallet',
  'Certificates',
  'Settings',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _user = AppDependencies.authRepository.currentUser;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final user = await AppDependencies.authRepository.fetchProfile();
    if (mounted && user != null) setState(() => _user = user);
  }

  String get _name => _user?.displayName ?? _fallbackName;
  String get _email =>
      (_user?.email.isNotEmpty ?? false) ? _user!.email : _fallbackEmail;
  String get _initial => _user?.initial ?? _fallbackName.substring(0, 1);

  Future<void> _logout() async {
    await AppDependencies.authRepository.logout();
    if (!mounted) return;
    context.go('/login');
  }

  static const _menuRoutes = <String, String>{
    'Edit Profile': '/profile/edit',
    'My Courses': '/learn',
    'Wallet': '/wallet',
    'Certificates': '/certificates',
    'Portfolio': '/portfolio',
    'Settings': '/settings',
    'Help Center': '/help',
  };

  void _openMenu(String item) {
    final route = _menuRoutes[item];
    if (route == null) return;
    // My Courses is a tab (replace); the rest are pushed so Back returns here.
    if (route == '/learn') {
      context.go(route);
    } else {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(mobile: _buildMobile, desktop: _buildDesktop);
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: CenteredContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    AppAvatar(initial: _initial, size: 72, fontSize: 24),
                    const SizedBox(height: 10),
                    Text(
                      _name,
                      style: AppTypography.base(16, weight: FontWeight.w700),
                    ),
                    Text(
                      _email,
                      style: AppTypography.base(
                        12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (final item in _menuItems) ...[
                  AppCard(
                    onTap: () => _openMenu(item),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item, style: AppTypography.base(13)),
                        const Text(
                          '›',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                AppCard(
                  onTap: _logout,
                  child: Text(
                    'Logout',
                    style: AppTypography.base(13, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (i) => NavTargets.onTab(context, i),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar is not in the Profile mockup; kept for navigation.
          AppSidebar(
            activeKey: '',
            onSelect: (k) => NavTargets.onSidebar(context, k),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 260,
                      child: Column(
                        children: [
                          AppAvatar(initial: _initial, size: 88, fontSize: 28),
                          const SizedBox(height: 12),
                          Text(
                            _name,
                            textAlign: TextAlign.center,
                            style: AppTypography.base(
                              17,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _email,
                            style: AppTypography.base(
                              12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const AppProgressBar(value: _learningProgress),
                          const SizedBox(height: 6),
                          Text(
                            '${(_learningProgress * 100).round()}% Learning Progress',
                            style: AppTypography.base(
                              11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton.ghost(label: 'Logout', onPressed: _logout),
                        ],
                      ),
                    ),
                    const SizedBox(width: 36),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0;
                                    i < _desktopTabs.length;
                                    i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  AppChip(
                                    label: _desktopTabs[i],
                                    active: i == 0,
                                    onTap: () => _openMenu(_desktopTabs[i]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          CardGrid(
                            columns: 3,
                            children: [
                              for (final s in _stats)
                                KpiCard(label: s.label, value: s.value),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
