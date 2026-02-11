
class AuthState {
  final bool isLoggedIn;

  const AuthState({
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    bool? isLoggedIn
  }) {
    return AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn
    );
  }
}