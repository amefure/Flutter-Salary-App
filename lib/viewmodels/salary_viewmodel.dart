import 'package:flutter/material.dart';
import 'package:salary/repository/realm_repository.dart';
import '../models/salary.dart';

/// Salary操作するViewModel
/// [ChangeNotifier]で状態管理
/// main.dartにて[MultiProvider]で設定
class SalaryViewModel extends ChangeNotifier {
  /// 引数でRepositoryをセット
  final RealmRepository _repository;

  /// Salary リスト
  List<Salary> salaries = [];

  /// 引数付きコンストラクタ
  SalaryViewModel(this._repository) {
    // 初期化時に全データを取得
    fetchAll();
  }

  /// Salaryの全データ取得
  void fetchAll() {
    salaries = _repository.fetchAll<Salary>();
    // 日付の降順
    salaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  /// 追加
  void add(Salary salary) {
    _repository.add<Salary>(salary);
    fetchAll();
  }

  /// 削除
  void delete(Salary salary) {
    _repository.delete<Salary>(salary);
    fetchAll();
  }
}
