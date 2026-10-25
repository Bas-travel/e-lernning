import 'package:flutter/foundation.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';

class RegisterController extends ChangeNotifier {
  RegisterController({AuthRepository? repository})
      : _repository = repository ?? AppDependencies.authRepository;

  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );

      isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      isLoading = false;
      errorMessage = error.message;
      notifyListeners();
      return errorMessage;
    } catch (_) {
      isLoading = false;
      errorMessage = 'สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
      notifyListeners();
      return errorMessage;
    }
  }
}
