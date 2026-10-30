import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';

class RegisterController extends ChangeNotifier {
  RegisterController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      return null;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return errorMessage;
    } catch (_) {
      errorMessage = 'สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
      return errorMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
