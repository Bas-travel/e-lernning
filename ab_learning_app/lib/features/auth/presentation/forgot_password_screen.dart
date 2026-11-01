import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/rest_exception.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/hifi_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/inline_banner.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_loading) return;
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'กรุณากรอกอีเมลที่ลงทะเบียนไว้');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AppDependencies.authRepository.forgotPassword(email: _email.text);
      if (mounted) setState(() => _sent = true);
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      cardWidth: 400,
      mobilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      builder: (context, desktop) {
        final titleStyle = AppTypography.base(
          desktop ? 19 : 17,
          weight: FontWeight.w700,
        );
        final bodyStyle = AppTypography.base(
          desktop ? 13 : 12.5,
          color: AppColors.textSecondary,
        );

        if (_sent) {
          // Confirmation state (spec 07). Copy is a draft: the mockup only
          // shows the form state.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.pillSuccessBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 28,
                    color: AppColors.pillSuccessFg,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('ส่งลิงก์รีเซ็ตแล้ว',
                  textAlign: TextAlign.center, style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'ตรวจสอบกล่องอีเมลของคุณและทำตามขั้นตอนเพื่อตั้งรหัสผ่านใหม่',
                textAlign: TextAlign.center,
                style: bodyStyle,
              ),
              SizedBox(height: desktop ? 22 : 20),
              AppButton.primary(
                label: 'กลับไปเข้าสู่ระบบ',
                onPressed: () => context.go('/login'),
                expand: true,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ลืมรหัสผ่าน?', style: titleStyle),
            SizedBox(height: desktop ? 8 : 6),
            Text(
              'กรอกอีเมลที่ลงทะเบียนไว้ เราจะส่งลิงก์รีเซ็ตให้',
              style: bodyStyle,
            ),
            SizedBox(height: desktop ? 22 : 20),
            if (_error != null) ...[
              InlineBanner(message: _error!),
              const SizedBox(height: 14),
            ],
            HifiTextField(
              controller: _email,
              hint: 'Email',
              fontSize: desktop ? 13.5 : 13,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => _send(),
            ),
            SizedBox(height: desktop ? 18 : 16),
            AppButton.primary(
              label: 'Send Reset Link',
              onPressed: _send,
              loading: _loading,
              expand: true,
            ),
          ],
        );
      },
    );
  }
}
