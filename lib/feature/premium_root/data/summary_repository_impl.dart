import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/premium_root/data/dto/summary_dto.dart';
import 'package:salary/feature/premium_root/data/summary_api.dart';
import 'package:salary/feature/premium_root/domain/summary_repository.dart';

final summaryRepositoryImplProvider = Provider<SummaryRepository>((ref) {
  final apiSource = ref.read(summaryApiProvider);
  return SummaryRepositoryImpl(apiSource);
});

class SummaryRepositoryImpl implements SummaryRepository {
  SummaryRepositoryImpl(this._api);

  final SummaryApi _api;

  @override
  Future<SummaryDto> dashboard() async {
    final result = await _api.dashboard();
    logger(result);
    return SummaryDto.fromJson(result);
  }
}
