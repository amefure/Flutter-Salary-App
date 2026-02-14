class AuthUser {
  final int id;
  final String name;
  final String email;
  final String region;
  final DateTime birthday;
  final String job;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.region,
    required this.birthday,
    required this.job,
  });

  AuthUser copyWith({
    String? name,
    String? email,
    String? region,
    DateTime? birthday,
    String? job,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      region: region ?? this.region,
      birthday: birthday ?? this.birthday,
      job: job ?? this.job,
    );
  }
}
