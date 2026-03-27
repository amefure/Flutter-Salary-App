import 'package:salary/core/config/json_keys.dart';
import 'package:salary/feature/salary/data/dto/salary_dto.dart';

class SalaryPageDto {
  final List<SalaryDto> salaries;
  final int? currentPage;
  final int? lastPage;
  final int? total;

  SalaryPageDto({
    required this.salaries,
    this.currentPage,
    this.lastPage,
    this.total,
  });

  factory SalaryPageDto.fromJson(Map<String, dynamic> json) {
    final salariesJson = json[CommonJsonKeys.data][CommonJsonKeys.salaries];

    return SalaryPageDto(
      salaries: (salariesJson[CommonJsonKeys.data] as List)
          .map((e) => SalaryDto.fromJson(e))
          .toList(),
      currentPage: salariesJson[PageKeys.currentPage],
      lastPage: salariesJson[PageKeys.lastPage],
      total: salariesJson[PageKeys.total],
    );
  }
}
