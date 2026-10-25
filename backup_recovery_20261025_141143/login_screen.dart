import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// <<<<<<< design/tokens-update
// =======
// import '../../../core/theme/colors.dart';
// import '../../../core/theme/radius.dart';
// import '../../../core/theme/shadows.dart';
// import '../../../core/theme/typography.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/brand_mark.dart';
// import '../../../core/widgets/inline_banner.dart';
// import '../../../core/widgets/responsive.dart';
// >>>>>>> main
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
// <<<<<<< design/tokens-update
//   final _controller = LoginController();
// =======
//   final _loginController = LoginController();
//   bool _rememberMe = true;
// >>>>>>> main

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
// <<<<<<< design/tokens-update
//     _controller.dispose();
// =======
//     _loginController.dispose();
// >>>>>>> main
    super.dispose();
  }

  Future<void> _login() async {
// <<<<<<< design/tokens-update
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     final error = await _controller.login(email: email, password: password);
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
//     if (_loginController.isLoading) return;
//     FocusScope.of(context).unfocus();
//     final ok = await _loginController.login(
//       identifier: _emailController.text,
//       password: _passwordController.text,
//       remember: _rememberMe,
//     );
//     if (!mounted || !ok) return;
//     context.go('/home');
// >>>>>>> main
  }

  @override
  Widget build(BuildContext context) {
// <<<<<<< design/tokens-update
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, _) {
//         return Scaffold(
//           appBar: AppBar(title: const Text('Login')),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
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
//                   onPressed: _controller.isLoading ? null : _login,
//                   child: _controller.isLoading
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Login'),
//                 ),
//                 const SizedBox(height: 12),
//                 TextButton(
//                   onPressed: () => context.go('/register'),
//                   child: const Text("Don't have an account? Register"),
//                 ),//ลงทะเบียน
//               ],
//             ),
//           ),
//         );
//       },
// =======
//     return Scaffold(
//       body: ResponsiveBuilder(
//         mobile: (_) => SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//               child: ConstrainedBox(
//                 constraints:
//                     const BoxConstraints(maxWidth: Breakpoints.mobileContentMax),
//                 child: _LoginForm(
//                   desktop: false,
//                   emailController: _emailController,
//                   passwordController: _passwordController,
//                   loginController: _loginController,
//                   rememberMe: _rememberMe,
//                   onRememberChanged: (v) => setState(() => _rememberMe = v),
//                   onSubmit: _login,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         desktop: (_) => Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: const BoxDecoration(gradient: AppGradients.authTint),
//           child: SafeArea(
//             child: Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Container(
//                   width: 420,
//                   padding: const EdgeInsets.all(40),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(AppRadius.modal),
//                     boxShadow: AppShadows.authCard,
//                   ),
//                   child: _LoginForm(
//                     desktop: true,
//                     emailController: _emailController,
//                     passwordController: _passwordController,
//                     loginController: _loginController,
//                     rememberMe: _rememberMe,
//                     onRememberChanged: (v) => setState(() => _rememberMe = v),
//                     onSubmit: _login,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LoginForm extends StatelessWidget {
//   const _LoginForm({
//     required this.desktop,
//     required this.emailController,
//     required this.passwordController,
//     required this.loginController,
//     required this.rememberMe,
//     required this.onRememberChanged,
//     required this.onSubmit,
//   });

//   final bool desktop;
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final LoginController loginController;
//   final bool rememberMe;
//   final ValueChanged<bool> onRememberChanged;
//   final VoidCallback onSubmit;

//   @override
//   Widget build(BuildContext context) {
//     final labelSize = desktop ? 12.0 : 11.0;
//     final inputSize = desktop ? 13.5 : 13.0;
//     final smallSize = desktop ? 12.0 : 11.5;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Column(
//           children: [
//             BrandMark(
//               size: desktop ? 52 : 56,
//               radius: desktop ? 14 : 16,
//             ),
//             SizedBox(height: desktop ? 10 : 12),
//             Text(
//               'AB LEARNING',
//               style: AppTypography.base(
//                 desktop ? 19 : 18,
//                 weight: FontWeight.w700,
//               ),
//             ),
//             Text(
//               'Learn · Live · Community · Career',
//               style: AppTypography.base(
//                 desktop ? 12.5 : 12,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: desktop ? 28 : 34),
//         ListenableBuilder(
//           listenable: loginController,
//           builder: (context, _) {
//             final message = loginController.errorMessage;
//             if (message == null) return const SizedBox.shrink();
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 14),
//               child: InlineBanner(message: message),
//             );
//           },
//         ),
//         _FieldLabel('Email or phone', size: labelSize),
//         TextField(
//           controller: emailController,
//           keyboardType: TextInputType.emailAddress,
//           textInputAction: TextInputAction.next,
//           autofillHints: const [AutofillHints.username],
//           onChanged: (_) => loginController.clearError(),
//           style: AppTypography.base(inputSize),
//         ),
//         SizedBox(height: desktop ? 14 : 12),
//         _FieldLabel('Password', size: labelSize),
//         TextField(
//           controller: passwordController,
//           obscureText: true,
//           textInputAction: TextInputAction.done,
//           autofillHints: const [AutofillHints.password],
//           onSubmitted: (_) => onSubmit(),
//           onChanged: (_) => loginController.clearError(),
//           style: AppTypography.base(inputSize),
//         ),
//         SizedBox(height: desktop ? 10 : 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Flexible(
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: () => onRememberChanged(!rememberMe),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: Checkbox(
//                         value: rememberMe,
//                         onChanged: (v) => onRememberChanged(v ?? false),
//                         activeColor: AppColors.primary,
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         visualDensity: VisualDensity.compact,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Flexible(
//                       child: Text(
//                         'Remember me',
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTypography.base(
//                           smallSize,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Flexible(
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: () => context.push('/forgot-password'),
//                 child: Text(
//                   'Forgot password?',
//                   textAlign: TextAlign.end,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTypography.base(
//                     smallSize,
//                     weight: FontWeight.w600,
//                     color: AppColors.primary,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: desktop ? 20 : 18),
//         ListenableBuilder(
//           listenable: loginController,
//           builder: (context, _) => AppButton.primary(
//             label: 'Log in',
//             onPressed: onSubmit,
//             loading: loginController.isLoading,
//             expand: true,
//           ),
//         ),
//         SizedBox(height: desktop ? 18 : 16),
//         Center(
//           child: Text(
//             'or continue with',
//             style: AppTypography.base(
//               desktop ? 11.5 : 11,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         const SizedBox(height: 14),
//         // TODO(auth): social sign-in is not wired (no provider config yet).
//         Row(
//           children: [
//             Expanded(child: AppButton.ghost(label: 'Google', onPressed: () {})),
//             const SizedBox(width: 8),
//             Expanded(
//               child: AppButton.ghost(label: 'Facebook', onPressed: () {}),
//             ),
//             const SizedBox(width: 8),
//             Expanded(child: AppButton.ghost(label: 'LINE', onPressed: () {})),
//           ],
//         ),
//         SizedBox(height: desktop ? 22 : 20),
//         Wrap(
//           alignment: WrapAlignment.center,
//           children: [
//             Text(
//               "Don't have an account? ",
//               style: AppTypography.base(
//                 desktop ? 12.5 : 12,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: () => context.push('/register'),
//               child: Text(
//                 'Register',
//                 style: AppTypography.base(
//                   desktop ? 12.5 : 12,
//                   weight: FontWeight.w600,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _FieldLabel extends StatelessWidget {
//   const _FieldLabel(this.text, {required this.size});

//   final String text;
//   final double size;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Text(
//         text,
//         style: AppTypography.base(size, color: AppColors.textSecondary),
//       ),
// >>>>>>> main
    );
  }
}
