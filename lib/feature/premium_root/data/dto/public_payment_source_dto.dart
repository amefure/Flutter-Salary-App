import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/premium_root/domain/model/public_payment_source.dart';

class PublicPaymentSourceDto {

  final String id;
  final String publicName;

  PublicPaymentSourceDto({
    required this.id,
    required this.publicName,
  });

  factory PublicPaymentSourceDto.fromJson(Map<String, dynamic> json) {
    return PublicPaymentSourceDto(
      id: json[PaymentSourceJsonKeys.id],
      publicName: json[PaymentSourceJsonKeys.publicName],
    );
  }
}

extension PublicPaymentSourceDtoMapper on PublicPaymentSourceDto {
  PublicPaymentSource toDomain() {
    return PublicPaymentSource(
      id: id,
      publicName: publicName,
    );
  }
}
