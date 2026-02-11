import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/token_storage.dart';
import 'package:salary/core/auth/auth_state.dart';

final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>(
      (ref) => AuthController(TokenStorage()),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._tokenStorage) : super(const AuthState());

  final TokenStorage _tokenStorage;

  Future<void> checkLogin() async {
    final token = await _tokenStorage.read();
    state = state.copyWith(
      isLoggedIn: token != null,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    state = state.copyWith(isLoggedIn: false);
  }
}
