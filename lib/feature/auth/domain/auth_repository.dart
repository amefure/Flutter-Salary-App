
import 'package:salary/feature/auth/domain/auth_user.dart';

/// 実態：[AuthRepositoryImpl]
abstract class AuthRepository {
  /// 会員登録
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String region,
    required DateTime birthday,
    required String job,
    required String jobCategory,
  });

  /// ログイン
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  /// ログアウト
  Future<void> logout();

  /// 退会
  Future<void> withdrawal();


  /// ログイン中ユーザー取得(ローカル)
  Future<AuthUser?> getCachedUser();

  /// ログイン中ユーザー取得
  Future<AuthUser> fetchUserFromApi();

  /// ローカルキャッシュユーザー情報の削除
  Future<void> clearCachedUser();

  /// プロフィール更新
  Future<void> updateProfile({
    required String name,
    required String region,
    required DateTime birthday,
    required String job,
    required String jobCategory
  });

  /// プロフィール更新(ポリシー限定)
  /// 同意日はサーバー側で生成する
  Future<void> updatePolicyProfile({
    required String publishPolicyVersion
  });

}
