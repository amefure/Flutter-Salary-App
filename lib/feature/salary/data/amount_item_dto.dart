import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';

class AmountItemDto {

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
      id: json[AmountItemJsonKeys.id],
      key: json[AmountItemJsonKeys.key],
      value: json[AmountItemJsonKeys.value],
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
