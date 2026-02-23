import 'package:salary/core/config/json_keys.dart';
import 'package:salary/feature/premium_root/data/dto/public_salary_dto.dart';
import 'package:salary/feature/premium_root/data/dto/public_user_dto.dart';
import 'package:salary/feature/premium_root/domain/model/public_salary.dart';
import 'package:salary/feature/premium_root/domain/model/public_user.dart';

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
extension PublicSalaryPageDtoMapper on PublicSalaryPageDto {
  List<PublicSalary> toDomain() {
    return salaries.map((e) => e.toDomain()).toList();
  }
}
