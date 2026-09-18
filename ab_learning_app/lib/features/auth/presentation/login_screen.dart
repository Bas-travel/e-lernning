import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_controller.dart';
import '../../../core/navigation/role_menus.dart';

/// Screen 03 — Login.
/// Layout notes (mobile vs desktop) match `01-screens-spec.md` exactly:
/// mobile is full-bleed with a bottom "Register" link, desktop centers a
/// 420px card on a tinted background.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController =
      TextEditingController(text: 'learner@ablearning.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _rememberMe = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final bool ok = await ref.read(authControllerProvider.notifier).login(
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
    if (ok && mounted) {
      final AppRole role = ref.read(authControllerProvider).role;
      context.go(homeRouteForRole(role));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
      }
    });

    final Widget form = _LoginForm(
      formKey: _formKey,
      identifierController: _identifierController,
      passwordController: _passwordController,
      rememberMe: _rememberMe,
      onRememberMeChanged: (v) => setState(() => _rememberMe = v),
      isLoading: authState.isLoading,
      onSubmit: _submit,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: (_) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: form,
          ),
          desktop: (_) => Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
              ),
            ),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.modal),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: form,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 12),
              const Text('AB LEARNING', style: AppTypography.h1),
              const SizedBox(height: 4),
              const Text(
                'Learn · Live · Community · Career',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Email or phone',
            controller: identifierController,
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.username],
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Password',
            controller: passwordController,
            obscureText: true,
            autofillHints: const <String>[AutofillHints.password],
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Checkbox(
                    value: rememberMe,
                    onChanged: (v) => onRememberMeChanged(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text('Remember me', style: AppTypography.caption),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Log in',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('or continue with', style: AppTypography.caption),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(child: GhostButton(label: 'Google', onPressed: () {})),
              const SizedBox(width: 8),
              Expanded(child: GhostButton(label: 'Facebook', onPressed: () {})),
              const SizedBox(width: 8),
              Expanded(child: GhostButton(label: 'LINE', onPressed: () {})),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTypography.caption,
                children: <InlineSpan>[
                  const TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: 'Register',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
