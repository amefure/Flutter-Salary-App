import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/salary/data/dto/salary_page_dto.dart';

/// 実態：[SalaryRepositoryImpl]
abstract class SalaryRepository {

  /// ユーザーに紐づいたデータのみ取得(ページネーションあり)
  Future<SalaryPageDto> fetchAllUserList({int page = 1});

  /// 全ユーザーのデータ取得(ページネーションあり)
  @Deprecated('公開・非公開に紐づかないデータ取得なので使用しない')
  Future<SalaryPageDto> fetchAllList({int page = 1});

  /// 一括作成
  Future<void> create({ required List<Salary> salaries });

  /// 更新
  Future<void> update({
    required String id,
    required String name,
    required int themeColor,
    required String? memo,
    required bool isMain,
  });

  /// 削除
  Future<void> delete({ required List<Salary> salaries });

}
