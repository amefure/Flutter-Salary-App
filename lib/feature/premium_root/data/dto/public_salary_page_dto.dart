import 'package:salary/core/config/json_keys.dart';
import 'package:salary/feature/premium_root/data/dto/public_salary_dto.dart';

class PublicSalaryPageDto {

  final List<PublicSalaryDto> salaries;
  final int currentPage;
  final int lastPage;
  final int total;

  PublicSalaryPageDto({
    required this.salaries,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PublicSalaryPageDto.fromJson(Map<String, dynamic> json) {
    return PublicSalaryPageDto(
      salaries: (json[CommonJsonKeys.data] as List)
          .map((e) => PublicSalaryDto.fromJson(e))
          .toList(),
      currentPage: json[PageKeys.currentPage],
      lastPage: json[PageKeys.lastPage],
      total: json[PageKeys.total],

    );
  }
}
