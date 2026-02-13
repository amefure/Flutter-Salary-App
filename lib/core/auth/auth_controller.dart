import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/api_exception.dart';
import 'package:salary/core/auth/auth_state.dart';
import 'package:salary/feature/auth/data/auth_repository_impl.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthController(authRepository);
  },
);

class AuthController extends StateNotifier<AuthState> {

  AuthController(this._authRepository) : super(const AuthState()) {
    // 初回インスタンス化時にユーザー情報を取得する
    fetchUser();
  }

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

  /// ログイン
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final user =  await _authRepository.login(
      email: email,
      password: password,
    );
    state = state.copyWith(user);
  }

  /// ユーザー情報取得
  Future<void> fetchUser() async {
    // すでにログイン済みなら取得しない
    if (state.isLogin) { return; }
    // ローカルからキャッシュユーザーを取得
    final cachedUser = await _authRepository.getCachedUser();
    if (cachedUser != null) {
      state = state.copyWith(cachedUser);
    }
    // 時間のかかるAPIは後から取得する
    try {
      final freshUser = await _authRepository.fetchUserFromApi();
      state = state.copyWith(freshUser);
    } on ApiException catch (e) {
      // 認証エラーならログアウト処理
      if (e.type == ApiErrorType.unauthorized) {
        await _authRepository.clearCachedUser();
        state = state.copyWith(null);
        return;
      }
    } catch (_) {
      // 通信エラーなどは無視
    }
  }

  /// ログアウト
  Future<void> logout() async {
    _authRepository.logout();
    state = state.copyWith(null);
  }
}
