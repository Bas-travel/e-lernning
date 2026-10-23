import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/auth_scaffold.dart';

const _otpLength = 6;
const _resendSeconds = 60;

/// TODO(api): masked phone number should come from the register response.
const _maskedPhone = '08X-XXX-1234';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _seconds = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _scheduleTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds <= 0) timer.cancel();
    });
  }

  void _resend() {
    // TODO(api): POST /api/v1/auth/verify-otp resend endpoint.
    _controller.clear();
    setState(() => _seconds = _resendSeconds);
    _scheduleTimer();
  }

  void _verify() {
    // Prototype stub: POST /api/v1/auth/verify-otp is not connected yet.
    context.go('/interests');
  }

  String get _countdownText {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return 'ขอรหัสใหม่ได้ใน $m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      cardWidth: 400,
      mobilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      builder: (context, desktop) {
        final boxW = desktop ? 44.0 : 40.0;
        final boxH = desktop ? 52.0 : 48.0;
        final boxGap = desktop ? 10.0 : 8.0;
        final code = _controller.text;

        final secondary = AppTypography.base(
          desktop ? 12.5 : 12,
          color: AppColors.textSecondary,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ยืนยันบัญชีของคุณ',
              textAlign: TextAlign.center,
              style: AppTypography.base(
                desktop ? 19 : 17,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(height: desktop ? 8 : 6),
            Text(
              'กรอกรหัส 6 หลักที่ส่งไปยัง $_maskedPhone',
              textAlign: TextAlign.center,
              style: AppTypography.base(
                desktop ? 13 : 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: desktop ? 28 : 26),
            Center(
              child: SizedBox(
                width: _otpLength * boxW + (_otpLength - 1) * boxGap,
                height: boxH,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < _otpLength; i++) ...[
                          if (i > 0) SizedBox(width: boxGap),
                          Container(
                            width: boxW,
                            height: boxH,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadius.input,
                              ),
                              border: Border.all(
                                color: i <= code.length
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              i < code.length ? code[i] : '',
                              style: AppTypography.base(
                                desktop ? 18 : 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Invisible field that receives the typing; the boxes above
                    // only render its text.
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          autofocus: true,
                          maxLength: _otpLength,
                          keyboardType: TextInputType.number,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          autofillHints: const [AutofillHints.oneTimeCode],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _verify(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: desktop ? 22 : 20),
            Center(
              child: _seconds > 0
                  ? Text(_countdownText, style: secondary)
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _resend,
                      child: Text(
                        'ส่งรหัสอีกครั้ง',
                        style: secondary.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: desktop ? 26 : 24),
            AppButton.primary(label: 'ยืนยัน', onPressed: _verify, expand: true),
          ],
        );
      },
    );
  }
}
