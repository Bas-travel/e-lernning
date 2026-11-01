import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/role_menus.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/mock/current_user.dart';
// import '../../../data/mock/models.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';
import 'auth_page_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late final _repository = widget.authRepository ?? AuthRepository();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final AuthResult result = await _repository.login(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      final User user = result.user;
      final role = _roleFor(user.role);
      CurrentUser.loginWith(
          role: role, name: user.fullName.trim(), email: user.email);
      context.go(homeRouteForRole(roleFromString(user.role)));
    } on ApiException catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyError(error));
    } catch (_) {
      if (mounted) {
        setState(
            () => _errorMessage = 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  AppRole _roleFor(String role) {
    switch (role) {
      case 'INSTRUCTOR':
        return AppRole.instructor;
      case 'CORP_ADMIN':
        return AppRole.corpAdmin;
      case 'CORP_MANAGER':
        return AppRole.corpManager;
      case 'EMPLOYER':
        return AppRole.employer;
      case 'ADMIN':
        return AppRole.admin;
      default:
        return AppRole.learner;
    }
  }

  String _friendlyError(ApiException error) {
    if (error.code == 'INVALID_CREDENTIALS' || error.statusCode == 401) {
      return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
    }
    if (error.code == 'NETWORK_ERROR') {
      return 'เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ตแล้วลองอีกครั้ง';
    }
    return error.message;
  }

  void _useDemoAccount() {
    _emailController.text = 'learner@ablearning.com';
    _passwordController.text = 'password123';
    setState(() => _errorMessage = null);
  }

  void _showPasswordResetNotice() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.mark_email_unread_outlined,
            color: AppColors.primary),
        title: const Text('รีเซ็ตรหัสผ่าน'),
        content: const Text(
            'ระบบส่งอีเมลรีเซ็ตรหัสผ่านยังไม่ได้เปิดใช้งาน กรุณาติดต่อผู้ดูแลระบบเพื่อขอความช่วยเหลือ'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('ปิด'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      title: 'ยินดีต้อนรับกลับ',
      subtitle: 'เข้าสู่ระบบเพื่อเรียนต่อจากจุดที่คุณหยุดไว้',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              _AuthErrorBanner(message: _errorMessage!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              key: const Key('login-email'),
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email
              ],
              onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'กรุณากรอกอีเมล';
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
                return null;
              },
              decoration: _inputDecoration(
                label: 'อีเมล',
                hint: 'name@example.com',
                icon: Icons.mail_outline,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('login-password'),
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _login(),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'กรุณากรอกรหัสผ่าน' : null,
              decoration: _inputDecoration(
                label: 'รหัสผ่าน',
                hint: 'กรอกรหัสผ่านของคุณ',
                icon: Icons.lock_outline,
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showPasswordResetNotice,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4)),
                child: const Text('ลืมรหัสผ่าน?'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton(
                key: const Key('login-submit'),
                onPressed: _isLoading ? null : _login,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('เข้าสู่ระบบ'),
              ),
            ),
            const SizedBox(height: 18),
            _DemoAccountPanel(onUseDemo: _useDemoAccount),
          ],
        ),
      ),
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('ยังไม่มีบัญชี?',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text('สมัครสมาชิก',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.pillErrorBg,
          borderRadius: BorderRadius.circular(AppRadius.input)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

class _DemoAccountPanel extends StatelessWidget {
  const _DemoAccountPanel({required this.onUseDemo});

  final VoidCallback onUseDemo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: const Color(0xFFDDE3FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined,
              color: AppColors.primary, size: 19),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ทดลองใช้งาน',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text('learner@ablearning.com  ·  password123',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          TextButton(onPressed: onUseDemo, child: const Text('เติมให้')),
        ],
      ),
    );
  }
}
