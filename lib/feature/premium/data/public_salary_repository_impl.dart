import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/json_keys.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/premium/data/dto/public_salary_page_dto.dart';
import 'package:salary/feature/premium/data/public_salary_api.dart';
import 'package:salary/feature/premium/domain/public_salary_repository.dart';

final publicSalaryRepositoryProvider = Provider<PublicSalaryRepository>((ref) {
  final apiSource = ref.read(publicSalaryApiProvider);
  return PublicSalaryRepositoryImpl(apiSource);
});

class PublicSalaryRepositoryImpl implements PublicSalaryRepository {
  PublicSalaryRepositoryImpl(this._api);

  final PublicSalaryApi _api;

  @override
  Future<PublicSalaryPageDto> fetchAllList({
    int page = 1,
    Map<String, dynamic>? queries
  }) async {
    final result = await _api.fetchAllList(page: page, queries: queries);
    logger(result);
    return PublicSalaryPageDto.fromJson(result);
  }

  /// 公開されている給料ユーザー数
  @override
  Future<int> fetchUserCount() async {
    final result = await _api.fetchUserCount();
    logger(result);
    return result[CommonJsonKeys.data][CommonJsonKeys.usersCount];
  }
}
