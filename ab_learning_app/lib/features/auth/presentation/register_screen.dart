import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import 'auth_page_layout.dart';
import 'register_controller.dart';
import '../data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late final _controller =
      RegisterController(repository: widget.authRepository);
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final error = await _controller.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (error != null) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline,
            color: AppColors.success, size: 46),
        title: const Text('สร้างบัญชีเรียบร้อย'),
        content: Text(
            'บัญชีผู้เรียนสำหรับ ${_emailController.text.trim()} พร้อมใช้งานแล้ว เข้าสู่ระบบเพื่อเริ่มเรียนได้เลย'),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ไปหน้าเข้าสู่ระบบ'),
            ),
          ),
        ],
      ),
    );
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => AuthPageLayout(
        title: 'สร้างบัญชีใหม่',
        subtitle: 'เริ่มต้นเส้นทางการเรียนรู้ของคุณวันนี้',
        form: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_controller.errorMessage != null) ...[
                _RegisterErrorBanner(message: _controller.errorMessage!),
                const SizedBox(height: 16),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('register-first-name'),
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.givenName],
                      validator: (value) =>
                          (value?.trim().isEmpty ?? true) ? 'กรอกชื่อ' : null,
                      decoration:
                          _registerDecoration('ชื่อ', Icons.person_outline),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('register-last-name'),
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.familyName],
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'กรอกนามสกุล'
                          : null,
                      decoration:
                          _registerDecoration('นามสกุล', Icons.person_outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                key: const Key('register-email'),
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'กรุณากรอกอีเมล';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                    return 'รูปแบบอีเมลไม่ถูกต้อง';
                  }
                  return null;
                },
                decoration: _registerDecoration('อีเมล', Icons.mail_outline,
                    hint: 'name@example.com'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                key: const Key('register-password'),
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาตั้งรหัสผ่าน';
                  }
                  if (value.length < 8) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                  }
                  return null;
                },
                decoration: _registerDecoration(
                  'รหัสผ่าน',
                  Icons.lock_outline,
                  hint: 'อย่างน้อย 8 ตัวอักษร',
                  suffix: IconButton(
                    tooltip: _obscurePassword ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                key: const Key('register-confirm-password'),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmation,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _register(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณายืนยันรหัสผ่าน';
                  }
                  if (value != _passwordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
                decoration: _registerDecoration(
                  'ยืนยันรหัสผ่าน',
                  Icons.lock_reset_outlined,
                  suffix: IconButton(
                    tooltip:
                        _obscureConfirmation ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                    onPressed: () => setState(
                        () => _obscureConfirmation = !_obscureConfirmation),
                    icon: Icon(_obscureConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'สมัครเป็นบัญชีผู้เรียน ข้อมูลที่ต้องใช้มีเพียงชื่อ อีเมล และรหัสผ่าน',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton(
                  key: const Key('register-submit'),
                  onPressed: _controller.isLoading ? null : _register,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  child: _controller.isLoading
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('สร้างบัญชี'),
                ),
              ),
            ],
          ),
        ),
        footer: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('มีบัญชีอยู่แล้ว?',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary)),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('เข้าสู่ระบบ',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _registerDecoration(String label, IconData icon,
    {String? hint, Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.cardBorder)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.cardBorder)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  );
}

class _RegisterErrorBanner extends StatelessWidget {
  const _RegisterErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.pillErrorBg,
          borderRadius: BorderRadius.circular(AppRadius.input)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 19, color: AppColors.error),
          const SizedBox(width: 9),
          Expanded(
              child: Text(message,
                  style:
                      AppTypography.caption.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }
}
