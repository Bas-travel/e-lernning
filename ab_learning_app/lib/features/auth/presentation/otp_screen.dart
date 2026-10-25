import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/rest_exception.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/inline_banner.dart';

const _otpLength = 6;
const _resendSeconds = 60;

/// Data handed over from Register through the router `extra`.
class OtpArgs {
  const OtpArgs({
    this.userId,
    this.destination,
    this.identifier,
    this.password,
  });

  /// `user_id` returned by `POST /auth/register`.
  final int? userId;

  /// Where the code was sent (masked phone, or the e-mail address).
  final String? destination;

  /// Credentials kept in memory only to sign in right after verification
  /// (verify-otp returns no tokens).
  final String? identifier;
  final String? password;
}

/// `0812345678` -> `08X-XXX-5678`. Returns null when there is no usable phone.
String? maskPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 7) return null;
  return '${digits.substring(0, 2)}X-XXX-${digits.substring(digits.length - 4)}';
}

/// Shown when the screen is opened without [OtpArgs] (prototype / deep link).
const _fallbackDestination = '08X-XXX-1234';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.args});

  final OtpArgs? args;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _seconds = _resendSeconds;
  bool _loading = false;
  String? _error;

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

  Future<void> _verify() async {
    if (_loading) return;
    final args = widget.args;
    final userId = args?.userId;

    // Without a user id (prototype / mock flow) there is nothing to verify.
    if (userId == null) {
      context.go('/interests');
      return;
    }
    if (_controller.text.length != _otpLength) {
      setState(() => _error = 'กรุณากรอกรหัส $_otpLength หลัก');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = AppDependencies.authRepository;
    try {
      await repo.verifyOtp(userId: userId, code: _controller.text);
      // verify-otp returns no tokens: sign in with the credentials from
      // Register so the preferences step is authenticated. Failure is not
      // fatal; the user can log in manually later.
      final identifier = args?.identifier;
      final password = args?.password;
      if (identifier != null && password != null) {
        try {
          await repo.login(identifier: identifier, password: password);
        } catch (_) {}
      }
      if (!mounted) return;
      context.go('/interests');
    } on RestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              'กรอกรหัส 6 หลักที่ส่งไปยัง ${widget.args?.destination ?? _fallbackDestination}',
              textAlign: TextAlign.center,
              style: AppTypography.base(
                desktop ? 13 : 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: desktop ? 28 : 26),
            if (_error != null) ...[
              InlineBanner(message: _error!),
              const SizedBox(height: 14),
            ],
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
            AppButton.primary(
              label: 'ยืนยัน',
              onPressed: _verify,
              loading: _loading,
              expand: true,
            ),
          ],
        );
      },
    );
  }
}
