import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/typography.dart';

/// Text input styled by the global [InputDecorationTheme] (10px radius, #E2E8F0).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.fontSize = 13,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.errorText,
    this.inputFormatters,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hint;
  final double fontSize;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      style: AppTypography.base(fontSize),
      decoration: InputDecoration(hintText: hint, errorText: errorText),
    );
  }
}
