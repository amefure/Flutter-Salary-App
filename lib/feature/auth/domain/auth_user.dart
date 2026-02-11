class AuthUser {
  final int id;
  final String email;
  final String region;
  final DateTime birthday;
  final String job;

  const AuthUser({
    required this.id,
    required this.email,
    required this.region,
    required this.birthday,
    required this.job,
  });
}
