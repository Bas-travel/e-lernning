import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/shadows.dart';
import 'responsive.dart';

/// Shell shared by Register / OTP / Interests / Forgot Password.
///
/// Mobile: top-aligned scrollable column with [mobilePadding] (keyboard safe).
/// Desktop: centred white card of [cardWidth] on the brand-tinted background.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.builder,
    required this.cardWidth,
    this.mobilePadding = const EdgeInsets.all(24),
    this.tinted = true,
  });

  /// Builds the content; `desktop` is true on wide screens.
  final Widget Function(BuildContext context, bool desktop) builder;
  final double cardWidth;
  final EdgeInsets mobilePadding;

  /// Brand-tinted gradient background (all auth screens but Interests).
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: (context) => SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: mobilePadding,
            child: CenteredContent(child: builder(context, false)),
          ),
        ),
        desktop: (context) => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: tinted ? AppGradients.authTint : null,
            color: tinted ? null : AppColors.background,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.modal),
                    boxShadow:
                        tinted ? AppShadows.authCard : AppShadows.neutralCard,
                  ),
                  child: builder(context, true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
