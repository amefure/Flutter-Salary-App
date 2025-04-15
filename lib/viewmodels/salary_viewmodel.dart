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

  void fetchFilter(String name) {
    fetchAll();
    salaries = salaries.where((s) => s.source?.name == name).toList();
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

  /// 更新
  void update(Salary oldSalary, Salary updateSalary) {
    // 後続でコピーオブジェクトで更新するため
    // 旧SalaryのpaymentAmountItems/deductionAmountItemsの中身を一度完全に削除する
    // forEachで実行すると管理下リストオブジェクト内での操作違反でエラーになるため
    // fromでコピーを作成してからループさせる
    for (var item in List.from(oldSalary.paymentAmountItems)) {
      _repository.delete(item);
    }
    for (var item in List.from(oldSalary.deductionAmountItems)) {
      _repository.delete(item);
    }

    // 更新処理
    _repository.updateById(oldSalary.id, (Salary salary) {
      // 総支給
      salary.paymentAmount = updateSalary.paymentAmount;
      // 控除額
      salary.deductionAmount = updateSalary.deductionAmount;
      // 手取り額
      salary.netSalary = updateSalary.netSalary;
      // 登録日
      salary.createdAt = updateSalary.createdAt;
      // 総支給構成要素(リストは一度クリアにしてから追加しないと更新できない)
      salary.paymentAmountItems.clear();
      salary.paymentAmountItems.addAll(updateSalary.paymentAmountItems);
      // 控除額構成要素
      salary.deductionAmountItems.clear();
      salary.deductionAmountItems.addAll(updateSalary.deductionAmountItems);
      // 支払い元
      salary.source = updateSalary.source;
      // MEMO
      salary.memo = updateSalary.memo;
    });
    fetchAll();
  }

  /// 削除
  void delete(Salary salary) {
    _repository.delete<Salary>(salary);
    fetchAll();
  }
}
