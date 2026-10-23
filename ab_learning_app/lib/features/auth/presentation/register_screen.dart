import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_check_row.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _acceptTerms = true;

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

  void _submit() {
    if (!_acceptTerms || _confirmError != null) return;
    // Prototype stub: POST /api/v1/auth/register is not connected yet.
    context.go('/otp');
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
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _first,
                    hint: 'First name',
                    fontSize: fs,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                  ),
                ),
                SizedBox(width: rowGap),
                Expanded(
                  child: AppTextField(
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
            AppTextField(
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
                    child: AppTextField(
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
                    child: AppTextField(
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
              AppTextField(
                controller: _phone,
                hint: 'Phone',
                fontSize: fs,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
              SizedBox(height: gap),
              AppTextField(
                controller: _password,
                hint: 'Password',
                fontSize: fs,
                obscure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: gap),
              AppTextField(
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
              onPressed: (_acceptTerms && _confirmError == null) ? _submit : null,
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
