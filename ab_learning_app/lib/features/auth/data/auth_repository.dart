class AuthRepository {
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    return {
      'token': 'stub-access-token',
      'email': email,
    };
  }
}
