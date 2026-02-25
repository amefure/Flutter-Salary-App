import 'package:salary/feature/premium_root/data/dto/summary_dto.dart';

/// 実態：[SummaryRepositoryImpl]
abstract class SummaryRepository {

  /// 公開されている給料情報一覧(タイムライン用)
  Future<SummaryDto> dashboard({Map<String, dynamic>? queries});
}
