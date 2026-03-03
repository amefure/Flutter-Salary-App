import 'package:salary/feature/premium/data/dto/public_salary_page_dto.dart';

/// 実態：[PublicSalaryRepositoryImpl]
abstract class PublicSalaryRepository {

  /// 公開されている給料情報一覧(タイムライン用)
  Future<PublicSalaryPageDto> fetchAllList({int page = 1});

  /// 公開されている給料ユーザー数
  Future<int> fetchUserCount();
}
