class AuthUser {
  final int id;
  final String email;
  final String prefecture;
  final DateTime birthday;
  final String job;

  const AuthUser({
    required this.id,
    required this.email,
    required this.prefecture,
    required this.birthday,
    required this.job,
  });
}
