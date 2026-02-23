import 'package:salary/feature/premium_root/data/dto/public_salary_page_dto.dart';

/// 実態：[PublicSalaryRepositoryImpl]
abstract class PublicSalaryRepository {

  /// 公開されている給料情報一覧(タイムライン用)
  Future<PublicSalaryPageDto> fetchAllList({int page = 1});

  /// 公開されている給料情報を集計した情報(サマリー用)
  Future<PublicSalaryPageDto> fetchSummaryInfo({int page = 1});


}
