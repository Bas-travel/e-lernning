import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'responsive.dart';

/// Shared frame for secondary pages (Settings, Wallet, Checkout, ...):
/// back button + title, a width-capped scrollable body, keyboard-safe.
///
/// The back button pops when possible, otherwise goes to [fallbackRoute] so a
/// deep link (or web refresh) never strands the user.
class SubPageScaffold extends StatelessWidget {
  const SubPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.fallbackRoute = '/profile',
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 24),
  });

  final String title;
  final List<Widget> children;
  final String fallbackRoute;

  /// Pinned below the scroll area (e.g. a chat input or a checkout button).
  final Widget? bottom;
  final EdgeInsetsGeometry padding;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CenteredContent(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => _back(context),
                      icon: const Icon(Icons.arrow_back, size: 22),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.base(17, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: padding,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: children,
                ),
              ),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small section caption used on secondary pages.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: AppTypography.base(
          12,
          weight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
