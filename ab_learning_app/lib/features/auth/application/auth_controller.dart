import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/navigation/role_menus.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';

/// Provider graph for the Auth feature — screens depend on
/// [authControllerProvider] only.
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

enum AuthStatus { idle, loading, authenticated, error }

class AuthState {
  const AuthState({this.status = AuthStatus.idle, this.user, this.errorMessage});

  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// The single source of truth `app_router.dart` and `RoleScaffold` read
  /// to decide which shell/menu to show. [AppRole.guest] whenever there's
  /// no authenticated user yet — never null, so callers don't need a
  /// separate "not logged in" branch on top of a role switch.
  AppRole get role => user == null ? AppRole.guest : roleFromString(user!.role);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Drives screen 03 (Login). Holds the single source of truth for "is
/// someone logged in" that `app_router.dart` reads to decide whether to
/// show Login or Home.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result =
          await _repository.login(identifier: identifier, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}
