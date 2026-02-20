import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/salary/data/salary_api.dart';
import 'package:salary/feature/salary/data/salary_dto.dart';
import 'package:salary/feature/salary/domain/salary_repository.dart';

final salaryRepositoryProvider = Provider<SalaryRepository>((ref) {
  final apiSource = ref.read(salaryApiProvider);
  return SalaryRepositoryImpl(apiSource);
});

class SalaryRepositoryImpl implements SalaryRepository {
  SalaryRepositoryImpl(this._api);

  final SalaryApi _api;

  @override
  Future<List<Salary>> fetchAllUserList() async {
    final result = await _api.fetchAllUserList();
    logger(result);
    final List<dynamic> list = result[CommonJsonKeys.data][CommonJsonKeys.salaries];
    return list.map((json) => SalaryDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<List<Salary>> fetchAllList() async {
    final result = await _api.fetchAllList();
    logger(result);
    final List<dynamic> list = result[CommonJsonKeys.data][CommonJsonKeys.salaries];
    return list.map((json) => SalaryDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<void> create({ required List<Salary> salaries }) async {
    final body = {
      /// 配列で一括登録
      CommonJsonKeys.salaries: salaries.map((salary) => salary.toJson()).toList(),
    };
    await _api.create(body);
  }


  @override
  Future<void> update({
    required String id,
    required String name,
    required int themeColor,
    required String? memo,
    required bool isMain,
  }) async {
    await _api.update(
        id,
        {
          PaymentSourceJsonKeys.name: name,
          PaymentSourceJsonKeys.themeColor: themeColor,
          PaymentSourceJsonKeys.memo: memo,
          PaymentSourceJsonKeys.isMain: isMain,
        });
  }

  @override
  Future<void> delete({ required List<Salary> salaries }) async {
    if (salaries.isEmpty) return;
    final ids = salaries.map((e) => e.id).toList();
    await _api.delete({
        CommonJsonKeys.ids: ids,
      }
    );
  }

}
