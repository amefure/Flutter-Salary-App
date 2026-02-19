import 'package:salary/core/models/salary.dart';

class AmountItemDto {
  static const keyId = 'id';
  static const keyKey = 'key';
  static const keyValue = 'value';

  final String id;
  final String key;
  final int value;

  AmountItemDto({
    required this.id,
    required this.key,
    required this.value,
  });

  factory AmountItemDto.fromJson(Map<String, dynamic> json) {
    return AmountItemDto(
      id: json[keyId],
      key: json[keyKey],
      value: json[keyValue],
    );
  }

  AmountItem toDomain() {
    return AmountItem(
      id,
      key,
      value,
    );
  }
}
