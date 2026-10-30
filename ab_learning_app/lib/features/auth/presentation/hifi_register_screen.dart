import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/rest_exception.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_check_row.dart';
import '../../../core/widgets/hifi_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/inline_banner.dart';
import 'otp_screen.dart';

class HifiRegisterScreen extends StatefulWidget {
  const HifiRegisterScreen({super.key});

  @override
  State<HifiRegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<HifiRegisterScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _acceptTerms = true;
  bool _loading = false;
  String? _error;

  /// The desktop mockup has no "confirm password" field; set while building.
  bool _showConfirm = true;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? get _confirmError {
    if (!_showConfirm || _confirm.text.isEmpty) return null;
    return _confirm.text == _password.text ? null : 'รหัสผ่านไม่ตรงกัน';
  }

  Future<void> _submit() async {
    if (_loading || !_acceptTerms || _confirmError != null) return;

    if (_first.text.trim().isEmpty ||
        _last.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.isEmpty) {
      setState(() {
        _error = 'กรุณากรอกชื่อ นามสกุล อีเมล และรหัสผ่านให้ครบ';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await AppDependencies.authRepository.register(
        firstName: _first.text,
        lastName: _last.text,
        email: _email.text,
        phone: _phone.text,
        password: _password.text,
      );

      if (!mounted) return;

      context.go(
        '/otp',
        extra: OtpArgs(
          userId: user.id,
          destination: maskPhone(_phone.text) ?? _email.text.trim(),
          identifier: _email.text.trim(),
          password: _password.text,
        ),
      );
    } on RestException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      cardWidth: 480,
      mobilePadding: const EdgeInsets.all(24),
      builder: (context, desktop) {
        _showConfirm = !desktop; // desktop mockup has no confirm field
        final fs = desktop ? 13.5 : 13.0;
        final gap = desktop ? 12.0 : 10.0;
        final rowGap = desktop ? 10.0 : 8.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'สร้างบัญชีใหม่',
              style: AppTypography.base(
                desktop ? 20 : 18,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'เริ่มต้นเส้นทางการเรียนรู้ของคุณ',
              style: AppTypography.base(
                desktop ? 13 : 12,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: desktop ? 22 : 18),
            if (_error != null) ...[
              InlineBanner(message: _error!),
              SizedBox(height: gap),
            ],
            Row(
              children: [
                Expanded(
                  child: HifiTextField(
                    controller: _first,
                    hint: 'First name',
                    fontSize: fs,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                  ),
                ),
                SizedBox(width: rowGap),
                Expanded(
                  child: HifiTextField(
                    controller: _last,
                    hint: 'Last name',
                    fontSize: fs,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            HifiTextField(
              controller: _email,
              hint: 'Email',
              fontSize: fs,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            SizedBox(height: gap),
            if (desktop)
              Row(
                children: [
                  Expanded(
                    child: HifiTextField(
                      controller: _phone,
                      hint: 'Phone',
                      fontSize: fs,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                  ),
                  SizedBox(width: rowGap),
                  Expanded(
                    child: HifiTextField(
                      controller: _password,
                      hint: 'Password',
                      fontSize: fs,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              )
            else ...[
              HifiTextField(
                controller: _phone,
                hint: 'Phone',
                fontSize: fs,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
              SizedBox(height: gap),
              HifiTextField(
                controller: _password,
                hint: 'Password',
                fontSize: fs,
                obscure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: gap),
              HifiTextField(
                controller: _confirm,
                hint: 'Confirm password',
                fontSize: fs,
                obscure: true,
                textInputAction: TextInputAction.done,
                errorText: _confirmError,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: AppCheckRow(
                value: _acceptTerms,
                onChanged: (v) => setState(() => _acceptTerms = v),
                label: 'ฉันยอมรับ Terms & Conditions',
                fontSize: desktop ? 12 : 11.5,
              ),
            ),
            SizedBox(height: desktop ? 18 : 16),
            AppButton.primary(
              label: 'Create Account',
              onPressed:
                  (_acceptTerms && _confirmError == null) ? _submit : null,
              loading: _loading,
              expand: true,
            ),
            SizedBox(height: desktop ? 16 : 14),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'มีบัญชีแล้ว? ',
                  style: AppTypography.base(
                    desktop ? 12.5 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Log in',
                    style: AppTypography.base(
                      desktop ? 12.5 : 12,
                      weight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
