import 'package:flutter/material.dart';

// <<<<<<< design/tokens-update
// import '../data/auth_repository.dart';

// class LoginController extends ChangeNotifier {
//   LoginController({AuthRepository? repository}) : _repository = repository ?? AuthRepository();

//   final AuthRepository _repository;

// =======
// import '../../../core/di/app_dependencies.dart';
// import '../../../core/network/api_exception.dart';
// import '../data/auth_repository.dart';

// class LoginController extends ChangeNotifier {
//   LoginController({AuthRepository? repository})
//       : _repository = repository ?? AppDependencies.authRepository;

//   final AuthRepository _repository;

//   static const missingFieldsMessage =
//       'กรุณากรอกอีเมลหรือเบอร์โทร และรหัสผ่าน';
//   static const unexpectedMessage = 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่';

// >>>>>>> main
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
// <<<<<<< design/tokens-update
//   String? get errorMessage => _errorMessage;

//   Future<String?> login({required String email, required String password}) async {
//     _isLoading = true;
// =======

//   /// User-facing message of the last failed attempt, or `null`.
//   String? get errorMessage => _errorMessage;

//   void clearError() {
//     if (_errorMessage == null) return;
// >>>>>>> main
    _errorMessage = null;
    notifyListeners();
  }

// <<<<<<< design/tokens-update
//     try {
//       final response = await _repository.login(email: email, password: password);
//       if (response['token'] == null || (response['token'] as String).isEmpty) {
//         return 'Authentication failed';
//       }
//       return null;
//     } catch (error) {
//       _errorMessage = error.toString();
//       return _errorMessage;
// =======
//   /// Returns `true` when the user is logged in. [identifier] is an email or a
//   /// phone number.
//   Future<bool> login({
//     required String identifier,
//     required String password,
//     bool remember = true,
//   }) async {
//     if (identifier.trim().isEmpty || password.isEmpty) {
//       _errorMessage = missingFieldsMessage;
//       notifyListeners();
//       return false;
//     }

//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       await _repository.login(
//         identifier: identifier,
//         password: password,
//         remember: remember,
//       );
//       return true;
//     } on ApiException catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } catch (_) {
//       _errorMessage = unexpectedMessage;
//       return false;
// >>>>>>> main
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
