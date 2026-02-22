class AuthUser {
  final int id;
  final String name;
  final String email;
  final String region;
  final DateTime birthday;
  final String job;
  final String jobCategory;
  /// 公開規約同意日時
  final DateTime? publishAgreedAt;
  /// 公開規約バージョン 形式:vX.X.X
  final String? publishPolicyVersion;


  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.region,
    required this.birthday,
    required this.job,
    required this.jobCategory,
    required this.publishAgreedAt,
    required this.publishPolicyVersion,
  });

  AuthUser copyWith({
    String? name,
    String? email,
    String? region,
    DateTime? birthday,
    String? job,
    String? jobCategory,
    DateTime? publishAgreedAt,
    String? publishPolicyVersion,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      region: region ?? this.region,
      birthday: birthday ?? this.birthday,
      job: job ?? this.job,
      jobCategory: jobCategory ?? this.jobCategory,
      publishAgreedAt: publishAgreedAt,
      publishPolicyVersion: publishPolicyVersion,
    );
  }
}
