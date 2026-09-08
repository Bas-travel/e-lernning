import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';

class RegisterController extends ChangeNotifier {
  RegisterController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(name: name, email: email, password: password);
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Registration failed. Please check your details and try again.';
      notifyListeners();
      return errorMessage;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}