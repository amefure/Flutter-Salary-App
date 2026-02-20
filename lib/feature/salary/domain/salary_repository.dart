import 'package:salary/core/models/salary.dart';

/// 実態：[SalaryRepositoryImpl]
abstract class SalaryRepository {

  /// ユーザーに紐づいたデータのみ取得
  Future<List<Salary>> fetchAllUserList();

  /// 全ユーザーのデータ取得
  Future<List<Salary>> fetchAllList();

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
