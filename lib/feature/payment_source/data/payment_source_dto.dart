import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';

class PaymentSourceDto {

  final String id;
  /// 名前
  final String name;
  /// カラー
  final int themeColor;
  /// MEMO
  final String? memo;
  /// 本業フラグ
  final bool isMain;
  /// 対象ユーザーID(公開)
  final int? publicUserId;

  PaymentSourceDto({
    required this.id,
    required this.name,
    required this.themeColor,
    required this.memo,
    required this.isMain,
    required this.publicUserId,
  });

  factory PaymentSourceDto.fromJson(Map<String, dynamic> json) {
    return PaymentSourceDto(
      id: json[PaymentSourceJsonKeys.id],
      name: json[PaymentSourceJsonKeys.name],
      themeColor: json[PaymentSourceJsonKeys.themeColor],
      memo: json[PaymentSourceJsonKeys.memo],
      isMain: json[PaymentSourceJsonKeys.isMain],
      publicUserId: json[PaymentSourceJsonKeys.userId],
    );
  }

  PaymentSource toDomain() {
    return PaymentSource(
        id,
        name,
        themeColor,
        memo: memo,
        isMain,
        publicUserId: publicUserId
    );
  }
}
