import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/api_exception.dart';
import 'package:salary/core/auth/auth_state.dart';
import 'package:salary/core/config/public_policy_config.dart';
import 'package:salary/feature/auth/data/auth_repository_impl.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
  },
);

class AuthStateNotifier extends StateNotifier<AuthState> {

  AuthStateNotifier(this._authRepository) : super(const AuthState()) {
    // 初回インスタンス化時にユーザー情報を取得する
    _fetchAndSetUpUser();
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
    required String jobCategory,
}) async {
    final user =  await _authRepository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      region: region,
      birthday: birthday,
      job: job,
      jobCategory: jobCategory
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

  /// ユーザー情報取得 & State更新
  Future<void> _fetchAndSetUpUser({
    bool isForce = false
  }) async {
    // すでにログイン済みなら取得しない && 強制取得かどうか
    if (state.isLogin && !isForce) { return; }
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
        _clearUser();
        return;
      }
    } catch (_) {
      // 通信エラーなどは無視
    }
  }

  /// ユーザー情報取得
  Future<AuthUser> fetchUser() async {
    // 時間のかかるAPIは後から取得する
    try {
      final freshUser = await _authRepository.fetchUserFromApi();
      state = state.copyWith(freshUser);
      return freshUser;
    } on ApiException catch (e) {
      // 認証エラーならログアウト処理
      if (e.type == ApiErrorType.unauthorized) {
        _clearUser();
      }
      rethrow;
    } catch (_) {
      // 通信エラーなどは無視
      rethrow;
    }
  }

  /// ログアウト
  Future<void> logout() async {
    _authRepository.logout();
    _clearUser();
  }

  /// 退会(アカウント削除)
  Future<void> withdrawal() async {
    _authRepository.withdrawal();
    _clearUser();
  }

  Future<void> _clearUser() async {
    // ローカルキャッシュユーザーを削除
    await _authRepository.clearCachedUser();
    // UIも更新
    state = state.copyWith(null);
  }

  /// プロフィール情報更新
  Future<void> updateProfile({
    required String name,
    required String region,
    required DateTime birthday,
    required String job,
    required String jobCategory,
  }) async {
    await _authRepository.updateProfile(
        name: name,
        region: region,
        birthday: birthday,
        job: job,
        jobCategory: jobCategory
    );
    final updateUser = state.user?.copyWith(
        name: name,
        region: region,
        birthday: birthday,
        job: job
    );
    state = state.copyWith(updateUser);
  }

  /// プロフィール情報更新
  Future<void> updatePolicyProfile() async {
    await _authRepository.updatePolicyProfile(
        publishPolicyVersion: PublicPolicyConfig.version,
    );
    // 同意日が更新されているので念のため再度取得する
    await fetchUser();
  }

}
