import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/salary/data/dto/salary_dto.dart';
import 'package:salary/feature/salary/data/salary_api.dart';
import 'package:salary/feature/salary/data/dto/salary_page_dto.dart';
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

    final List<dynamic> salariesJson = result[CommonJsonKeys.data][CommonJsonKeys.salaries];

    return salariesJson
        .map((json) => SalaryDto.fromJson(json as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  @Deprecated('公開・非公開に紐づかないデータ取得なので使用しない')
  Future<SalaryPageDto> fetchAllList({int page = 1}) async {
    final result = await _api.fetchAllList(page: page);
    logger(result);
    return SalaryPageDto.fromJson(result);
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
    required Salary salary
  }) async {
    await _api.update(id, salary.toJson());
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
