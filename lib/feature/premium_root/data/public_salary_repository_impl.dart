import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/premium_root/data/dto/public_salary_page_dto.dart';
import 'package:salary/feature/premium_root/data/public_salary_api.dart';
import 'package:salary/feature/premium_root/domain/public_salary_repository.dart';

final publicSalaryRepositoryProvider = Provider<PublicSalaryRepository>((ref) {
  final apiSource = ref.read(publicSalaryApiProvider);
  return PublicSalaryRepositoryImpl(apiSource);
});

class PublicSalaryRepositoryImpl implements PublicSalaryRepository {
  PublicSalaryRepositoryImpl(this._api);

  final PublicSalaryApi _api;

  @override
  Future<PublicSalaryPageDto> fetchAllList({int page = 1}) async {
    final result = await _api.fetchAllList(page: page);
    logger(result);
    return PublicSalaryPageDto.fromJson(result);
  }
}
