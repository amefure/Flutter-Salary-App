import 'package:salary/feature/premium/data/dto/public_salary_page_dto.dart';
import 'package:salary/feature/premium/domain/model/public_salary.dart';

/// 実態：[PublicSalaryRepositoryImpl]
abstract class PublicSalaryRepository {

  /// 公開されている給料情報一覧(タイムライン用)
  Future<PublicSalaryPageDto> fetchAllList({
    int page = 1,
    Map<String, dynamic>? queries
  });

  /// 詳細取得
  Future<PublicSalary> fetchById({ required String id });

  /// 公開されている給料ユーザー数
  Future<int> fetchUserCount();
}
