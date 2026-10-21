import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

enum _AppButtonKind { primary, secondary, ghost, inverse }

/// Buttons from the mockup: `.btn-p`, `.btn-s`, `.btn-g` and the white
/// "on gradient" button used inside hero cards.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.loading = false,
    this.fontSize = 13,
  })  : _kind = _AppButtonKind.primary,
        _padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 11);

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.loading = false,
    this.fontSize = 13,
  })  : _kind = _AppButtonKind.secondary,
        _padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 11);

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.loading = false,
    this.fontSize = 12,
  })  : _kind = _AppButtonKind.ghost,
        _padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9);

  /// White button with primary text, for use on gradient cards.
  const AppButton.inverse({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.loading = false,
    this.fontSize = 12,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  })  : _kind = _AppButtonKind.inverse,
        _padding = padding;

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool loading;
  final double fontSize;
  final _AppButtonKind _kind;
  final EdgeInsets _padding;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    final textStyle = AppTypography.base(
      fontSize,
      weight: _kind == _AppButtonKind.ghost ? FontWeight.w400 : FontWeight.w600,
      height: 1.2,
    );
    final VoidCallback? effectiveOnPressed = loading ? null : onPressed;

    final Color spinnerColor = _kind == _AppButtonKind.primary
        ? Colors.white
        : AppColors.primary;
    final Widget child = loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spinnerColor,
            ),
          )
        : Text(label, textAlign: TextAlign.center);

    final Widget button;
    switch (_kind) {
      case _AppButtonKind.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnPrimaryBg,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.btnPrimaryBg,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            padding: _padding,
            minimumSize: Size.zero,
            shape: shape,
            textStyle: textStyle,
          ),
          child: child,
        );
        break;
      case _AppButtonKind.inverse:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            padding: _padding,
            minimumSize: Size.zero,
            shape: shape,
            textStyle: textStyle,
          ),
          child: child,
        );
        break;
      case _AppButtonKind.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.btnOutlineBorder),
            padding: _padding,
            minimumSize: Size.zero,
            shape: shape,
            textStyle: textStyle,
          ),
          child: child,
        );
        break;
      case _AppButtonKind.ghost:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border),
            padding: _padding,
            minimumSize: Size.zero,
            shape: shape,
            textStyle: textStyle,
          ),
          child: child,
        );
        break;
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
