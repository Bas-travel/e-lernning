import 'package:flutter/material.dart';

import '../data/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController({AuthRepository? repository}) : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<String?> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(email: email, password: password);
      if (response['token'] == null || (response['token'] as String).isEmpty) {
        return 'Authentication failed';
      }
      return null;
    } catch (error) {
      _errorMessage = error.toString();
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
