class PublicPaymentSource {

  final String id;
  final String publicName;

  PublicPaymentSource({
    required this.id,
    required this.publicName,
  });

  String get displayName => publicName.isEmpty ? '未設定' : publicName;
}
