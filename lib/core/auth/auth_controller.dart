import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/token_storage.dart';
import 'package:salary/core/auth/auth_state.dart';
import 'package:salary/feature/auth/data/auth_repository_impl.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final authRepository = ref.read(authRepositoryProvider);
  return AuthController(tokenStorage, authRepository);
  },
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(
      this._tokenStorage,
      this._authRepository
      ) : super(const AuthState());

  final TokenStorage _tokenStorage;
  final AuthRepository _authRepository;

  /// 新規登録
  Future<void> registerAccount({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String region,
    required DateTime birthday,
    required String job,
}) async {
    final user =  await _authRepository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      region: region,
      birthday: birthday,
      job: job,
    );
    state = state.copyWith(user);
  }


  Future<void> logout() async {
    _authRepository.logout();
  }
}
