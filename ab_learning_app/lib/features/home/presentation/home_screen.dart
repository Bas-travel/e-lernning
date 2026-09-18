import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../application/home_controller.dart';
import '../models/home_feed.dart';
import 'widgets/desktop_home_layout.dart';
import 'widgets/mobile_home_layout.dart';

/// Screen 08 — Home.
/// Fetches `homeFeedProvider` and renders one of the 5 required states
/// (Loading / Empty / Error / Success — Disabled/Offline not relevant here)
/// before delegating to [MobileHomeLayout] or [DesktopHomeLayout].
///
/// NOTE on chrome: unlike the Phase 2 role dashboards
/// (`features/{instructor,corporate,employer,admin}/`), this screen does
/// NOT use `RoleScaffold` — it predates it and already has its own richer
/// chrome (personalized greeting, search/notification/coin/avatar icons)
/// matching `02-hifi-mockups.html`'s Home mockup more closely than
/// `RoleScaffold`'s generic `AppBar` would. Both nav systems point at the
/// same routes, so this is a cosmetic inconsistency, not a functional one
/// — worth reconciling (likely by giving `RoleScaffold` an optional custom
/// top-bar slot) before adding more Learner screens, so screens 09+ don't
/// have to choose between the two patterns.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeFeed> feedAsync = ref.watch(homeFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: feedAsync.when(
          loading: () => const _HomeLoading(),
          error: (Object error, StackTrace _) => _HomeError(
            onRetry: () => ref.invalidate(homeFeedProvider),
          ),
          data: (HomeFeed feed) {
            if (feed.recommended.isEmpty && feed.continueLearning.isEmpty) {
              return const _HomeEmpty();
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(homeFeedProvider.future),
              child: ResponsiveBuilder(
                mobile: (_) => MobileHomeLayout(feed: feed),
                desktop: (_) => DesktopHomeLayout(feed: feed),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    // Simple skeleton — swap for shimmer package if desired later.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List<Widget>.generate(
        4,
        (_) => Container(
          height: 96,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('โหลดข้อมูลไม่สำเร็จ', style: AppTypography.h2),
            const SizedBox(height: 6),
            const Text(
              'ตรวจสอบการเชื่อมต่อของคุณแล้วลองอีกครั้ง',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SecondaryButton(label: 'ลองอีกครั้ง', onPressed: onRetry, fullWidth: false),
          ],
        ),
      ),
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.explore_outlined, size: 40, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('ยังไม่มีคอร์สแนะนำ', style: AppTypography.h2),
            SizedBox(height: 6),
            Text(
              'ไปที่ Explore เพื่อเลือกคอร์สแรกของคุณ',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
