import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/charts/chart_salary_view_model.dart';
import 'package:salary/domain/detail_salary/detail_salary_state.dart';
import 'package:salary/domain/list_salary/list_salary_view_model.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/repository/realm_repository.dart';

final detailSalaryProvider =
StateNotifierProvider.autoDispose.family<DetailSalaryViewModel, DetailSalaryState, String>(
      (ref, id) {
    final repository = RealmRepository();
    return DetailSalaryViewModel(ref, repository)..loadSalary(id);
  },
);

class DetailSalaryViewModel extends StateNotifier<DetailSalaryState> {
  final Ref ref;

  /// 引数でRepositoryをセット
  final RealmRepository _repository;

  /// 初期インスタンス化
  DetailSalaryViewModel(this.ref, this._repository)
      : super(DetailSalaryState(salary: null));

  /// Realm から Salary を取得（Single Source of Truth設計)
  void loadSalary(String id) {
    final item = _repository.fetchById<Salary>(id);
    state = state.copyWith(salary: item?.freeze());
  }

  /// 詳細画面で表示対象のデータをリセット
  void _resetSalary() {
    state = state.copyWith(salary: null);
  }

  /// 削除
  void delete(Salary salary) {
    // 削除前にnullにして画面を更新
    _resetSalary();
    // 削除処理
    _repository.deleteById<Salary>(salary.id);
    // MyData画面のリフレッシュ
    ref.read(chartSalaryProvider.notifier).refresh();
    // Homeリスト画面のリフレッシュ
    ref.read(listSalaryProvider.notifier).refresh();
  }
}