
import 'package:salary/feature/auth/domain/auth_user.dart';

class AuthState {
  final AuthUser? user;

  const AuthState({
    this.user,
  });

  bool get isLogin => user != null;
  bool get isPolicyAgreed => user?.publishAgreedAt != null;

  AuthState copyWith(AuthUser? user) {
    return AuthState(
        user: user
    );
  }
}
