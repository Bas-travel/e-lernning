import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/rest_exception.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/hifi_text_field.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

/// Edits the display name through `PUT /me`. The email is shown read-only
/// (the API does not change it here).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final String _initialFirst;
  late final String _initialLast;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = AppDependencies.authRepository.currentUser;
    _initialFirst = user?.firstName?.trim() ?? '';
    _initialLast = user?.lastName?.trim() ?? '';
    _first = TextEditingController(text: _initialFirst);
    _last = TextEditingController(text: _initialLast);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  bool get _signedIn => AppDependencies.authRepository.currentUser != null;

  bool get _canSave {
    final first = _first.text.trim();
    final last = _last.text.trim();
    return _signedIn &&
        !_saving &&
        first.isNotEmpty &&
        last.isNotEmpty &&
        (first != _initialFirst || last != _initialLast);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AppDependencies.authRepository.updateProfile(
        firstName: _first.text,
        lastName: _last.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกโปรไฟล์แล้ว')),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile');
      }
    } on RestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          text,
          style: AppTypography.base(12, weight: FontWeight.w600),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final user = AppDependencies.authRepository.currentUser;
    final email = (user?.email.isNotEmpty ?? false)
        ? user!.email
        : 'learner@ablearning.com';

    return SubPageScaffold(
      title: 'Edit Profile',
      children: [
        const SizedBox(height: 8),
        Center(
          child: AppAvatar(
            initial: user?.initial ?? 'A',
            size: 72,
            fontSize: 24,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          InlineBanner(message: _error!),
        ],
        _label('ชื่อ'),
        HifiTextField(
          controller: _first,
          hint: 'ชื่อ',
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        _label('นามสกุล'),
        HifiTextField(
          controller: _last,
          hint: 'นามสกุล',
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _save(),
        ),
        _label('อีเมล'),
        AppCard(
          color: AppColors.chipBg,
          borderColor: AppColors.border,
          padding: const EdgeInsets.all(11),
          child: Text(email, style: AppTypography.base(13)),
        ),
        if (!_signedIn) ...[
          const SizedBox(height: 14),
          Text(
            'กรุณาเข้าสู่ระบบเพื่อแก้ไขโปรไฟล์',
            style: AppTypography.base(11, color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 16),
        AppButton.primary(
          label: 'บันทึก',
          loading: _saving,
          onPressed: _canSave ? _save : null,
          expand: true,
        ),
      ],
    );
  }
}
