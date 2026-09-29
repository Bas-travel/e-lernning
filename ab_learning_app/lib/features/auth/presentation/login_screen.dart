import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/current_user.dart';
import '../../../data/mock/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.learner;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Prototype stub: accept any credentials. Role selection below stands
    // in for the role the backend will return on `POST /api/v1/auth/login`
    // once real auth is wired up (see `05-openapi.yaml` AuthTokenResponse).
    CurrentUser.loginAs(_selectedRole);
    context.go(CurrentUser.homeRouteFor(_selectedRole));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 8),
          TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 24),
          Text('Continue as', style: AppTypography.h2.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'Demo helper until real accounts carry a role from the backend.',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UserRole.values.map((role) {
              final selected = role == _selectedRole;
              return ChoiceChip(
                label: Text(role.label),
                selected: selected,
                onSelected: (_) => setState(() => _selectedRole = role),
                selectedColor: AppColors.primary,
                labelStyle: AppTypography.caption.copyWith(
                  color: selected ? Colors.white : AppColors.text,
                ),
                backgroundColor: Colors.white,
                shape: const StadiumBorder(side: BorderSide(color: AppColors.cardBorder)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimaryBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              onPressed: _login,
              child: Text(
                'Login as ${_selectedRole.label}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
