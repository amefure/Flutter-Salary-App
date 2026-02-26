import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/feature/premium/data/dto/summary_dto.dart';
import 'package:salary/feature/premium/data/summary_api.dart';
import 'package:salary/feature/premium/domain/summary_repository.dart';

final summaryRepositoryImplProvider = Provider<SummaryRepository>((ref) {
  final apiSource = ref.read(summaryApiProvider);
  return SummaryRepositoryImpl(apiSource);
});

class SummaryRepositoryImpl implements SummaryRepository {
  SummaryRepositoryImpl(this._api);

  final SummaryApi _api;

  @override
  Future<SummaryDto> dashboard({Map<String, dynamic>? queries}) async {
    final result = await _api.dashboard(queries: queries);
    return SummaryDto.fromJson(result);
  }
}
