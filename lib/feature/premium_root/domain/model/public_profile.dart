class PublicProfile {

  final String jobCategory;
  final String job;
  final String region;
  final String ageRange;

  PublicProfile({
    required this.jobCategory,
    required this.job,
    required this.region,
    required this.ageRange,
  });

  bool get isInTokyo => region == '東京';
}
