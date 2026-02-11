
import 'package:salary/feature/auth/domain/auth_user.dart';

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

  /// ログイン中ユーザー取得
  Future<AuthUser> fetchUser();
}
