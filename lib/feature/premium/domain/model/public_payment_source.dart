import 'package:salary/core/models/salary.dart';
import 'package:salary/core/models/thema_color.dart';

class PublicPaymentSource {

  final String id;
  final String publicName;
  final int themaColor;

  PublicPaymentSource({
    required this.id,
    required this.publicName,
    required this.themaColor,
  });

  String get displayName => publicName.isEmpty ? '非公開' : publicName;
  /// ThemaColor に変換
  ThemaColor get themaColorEnum => ThemaColor.fromValue(themaColor);
}

extension PublicPaymentSourceMapper on PublicPaymentSource {
  PaymentSource toDomainLocal() {
    return PaymentSource(
      id,
      displayName,
      themaColor,
      false,
      publicName.isEmpty,
      memo: ''
    );
  }
}