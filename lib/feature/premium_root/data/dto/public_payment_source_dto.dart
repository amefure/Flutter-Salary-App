import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';

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

  PaymentSource toDomain() {
    return PaymentSource(
        id,
        publicName,
        0,
        memo: '',
        false,
        true,
        publicUserId: null
    );
  }
}
