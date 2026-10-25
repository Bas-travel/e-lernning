import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// <<<<<<< design/tokens-update
// import 'register_controller.dart';
// =======

// import '../../../core/di/app_dependencies.dart';
// import '../../../core/network/api_exception.dart';
// import '../../../core/theme/colors.dart';
// import '../../../core/theme/typography.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/app_check_row.dart';
// import '../../../core/widgets/app_text_field.dart';
// import '../../../core/widgets/auth_scaffold.dart';
// import '../../../core/widgets/inline_banner.dart';
// import 'otp_screen.dart';
// >>>>>>> main

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
// <<<<<<< design/tokens-update
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _controller = RegisterController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (password != confirmPassword) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Passwords do not match')),
//       );
//       return;
//     }

//     final error = await _controller.register(
//       name: name,
//       email: email,
//       password: password,
//     );

//     if (!mounted) {
//       return;
//     }
//     if (error == null) {
//       context.go('/home');
//       return;
//     }
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(error)),
//     );
// =======
//   final _first = TextEditingController();
//   final _last = TextEditingController();
//   final _email = TextEditingController();
//   final _phone = TextEditingController();
//   final _password = TextEditingController();
//   final _confirm = TextEditingController();
//   bool _acceptTerms = true;
//   bool _loading = false;
//   String? _error;

//   /// The desktop mockup has no "confirm password" field; set while building.
//   bool _showConfirm = true;

//   @override
//   void dispose() {
//     _first.dispose();
//     _last.dispose();
//     _email.dispose();
//     _phone.dispose();
//     _password.dispose();
//     _confirm.dispose();
//     super.dispose();
//   }

//   String? get _confirmError {
//     if (!_showConfirm || _confirm.text.isEmpty) return null;
//     return _confirm.text == _password.text ? null : 'รหัสผ่านไม่ตรงกัน';
//   }

//   Future<void> _submit() async {
//     if (_loading || !_acceptTerms || _confirmError != null) return;
//     if (_first.text.trim().isEmpty ||
//         _last.text.trim().isEmpty ||
//         _email.text.trim().isEmpty ||
//         _password.text.isEmpty) {
//       setState(() => _error = 'กรุณากรอกชื่อ นามสกุล อีเมล และรหัสผ่านให้ครบ');
//       return;
//     }
//     FocusScope.of(context).unfocus();
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final user = await AppDependencies.authRepository.register(
//         firstName: _first.text,
//         lastName: _last.text,
//         email: _email.text,
//         phone: _phone.text,
//         password: _password.text,
//       );
//       if (!mounted) return;
//       context.go(
//         '/otp',
//         extra: OtpArgs(
//           userId: user.id,
//           destination: maskPhone(_phone.text) ?? _email.text.trim(),
//           identifier: _email.text.trim(),
//           password: _password.text,
//         ),
//       );
//     } on ApiException catch (e) {
//       if (mounted) setState(() => _error = e.message);
//     } catch (_) {
//       if (mounted) {
//         setState(() => _error = 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่');
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
// >>>>>>> main
  }

  @override
  Widget build(BuildContext context) {
// <<<<<<< design/tokens-update
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, _) {
//         return Scaffold(
//           appBar: AppBar(title: const Text('Register')),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: 'Name'),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _passwordController,
//                   decoration: const InputDecoration(labelText: 'Password'),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _confirmPasswordController,
//                   decoration: const InputDecoration(labelText: 'Confirm Password'),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 16),
//                 if (_controller.errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Text(
//                       _controller.errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ElevatedButton(
//                   onPressed: _controller.isLoading ? null : _register,
//                   child: _controller.isLoading
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Create Account'),
//                 ),
//                 TextButton(
//                   onPressed: () => context.go('/login'),
//                   child: const Text('Already have an account? Login'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// =======
//     return AuthScaffold(
//       cardWidth: 480,
//       mobilePadding: const EdgeInsets.all(24),
//       builder: (context, desktop) {
//         _showConfirm = !desktop; // desktop mockup has no confirm field
//         final fs = desktop ? 13.5 : 13.0;
//         final gap = desktop ? 12.0 : 10.0;
//         final rowGap = desktop ? 10.0 : 8.0;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'สร้างบัญชีใหม่',
//               style: AppTypography.base(
//                 desktop ? 20 : 18,
//                 weight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'เริ่มต้นเส้นทางการเรียนรู้ของคุณ',
//               style: AppTypography.base(
//                 desktop ? 13 : 12,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             SizedBox(height: desktop ? 22 : 18),
//             if (_error != null) ...[
//               InlineBanner(message: _error!),
//               SizedBox(height: gap),
//             ],
//             Row(
//               children: [
//                 Expanded(
//                   child: AppTextField(
//                     controller: _first,
//                     hint: 'First name',
//                     fontSize: fs,
//                     textInputAction: TextInputAction.next,
//                     autofillHints: const [AutofillHints.givenName],
//                   ),
//                 ),
//                 SizedBox(width: rowGap),
//                 Expanded(
//                   child: AppTextField(
//                     controller: _last,
//                     hint: 'Last name',
//                     fontSize: fs,
//                     textInputAction: TextInputAction.next,
//                     autofillHints: const [AutofillHints.familyName],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: gap),
//             AppTextField(
//               controller: _email,
//               hint: 'Email',
//               fontSize: fs,
//               keyboardType: TextInputType.emailAddress,
//               textInputAction: TextInputAction.next,
//               autofillHints: const [AutofillHints.email],
//             ),
//             SizedBox(height: gap),
//             if (desktop)
//               Row(
//                 children: [
//                   Expanded(
//                     child: AppTextField(
//                       controller: _phone,
//                       hint: 'Phone',
//                       fontSize: fs,
//                       keyboardType: TextInputType.phone,
//                       textInputAction: TextInputAction.next,
//                       autofillHints: const [AutofillHints.telephoneNumber],
//                     ),
//                   ),
//                   SizedBox(width: rowGap),
//                   Expanded(
//                     child: AppTextField(
//                       controller: _password,
//                       hint: 'Password',
//                       fontSize: fs,
//                       obscure: true,
//                       textInputAction: TextInputAction.done,
//                       autofillHints: const [AutofillHints.newPassword],
//                       onSubmitted: (_) => _submit(),
//                     ),
//                   ),
//                 ],
//               )
//             else ...[
//               AppTextField(
//                 controller: _phone,
//                 hint: 'Phone',
//                 fontSize: fs,
//                 keyboardType: TextInputType.phone,
//                 textInputAction: TextInputAction.next,
//                 autofillHints: const [AutofillHints.telephoneNumber],
//               ),
//               SizedBox(height: gap),
//               AppTextField(
//                 controller: _password,
//                 hint: 'Password',
//                 fontSize: fs,
//                 obscure: true,
//                 textInputAction: TextInputAction.next,
//                 autofillHints: const [AutofillHints.newPassword],
//                 onChanged: (_) => setState(() {}),
//               ),
//               SizedBox(height: gap),
//               AppTextField(
//                 controller: _confirm,
//                 hint: 'Confirm password',
//                 fontSize: fs,
//                 obscure: true,
//                 textInputAction: TextInputAction.done,
//                 errorText: _confirmError,
//                 onChanged: (_) => setState(() {}),
//                 onSubmitted: (_) => _submit(),
//               ),
//             ],
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: AppCheckRow(
//                 value: _acceptTerms,
//                 onChanged: (v) => setState(() => _acceptTerms = v),
//                 label: 'ฉันยอมรับ Terms & Conditions',
//                 fontSize: desktop ? 12 : 11.5,
//               ),
//             ),
//             SizedBox(height: desktop ? 18 : 16),
//             AppButton.primary(
//               label: 'Create Account',
//               onPressed: (_acceptTerms && _confirmError == null) ? _submit : null,
//               loading: _loading,
//               expand: true,
//             ),
//             SizedBox(height: desktop ? 16 : 14),
//             Wrap(
//               alignment: WrapAlignment.center,
//               children: [
//                 Text(
//                   'มีบัญชีแล้ว? ',
//                   style: AppTypography.base(
//                     desktop ? 12.5 : 12,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTap: () => context.go('/login'),
//                   child: Text(
//                     'Log in',
//                     style: AppTypography.base(
//                       desktop ? 12.5 : 12,
//                       weight: FontWeight.w600,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
// >>>>>>> main
