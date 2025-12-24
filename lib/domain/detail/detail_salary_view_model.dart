import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/domain/detail/detail_salary_state.dart';
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

  /// Realm から Salary を取得
  void loadSalary(String id) {
    final item = _repository.fetchById<Salary>(id);
    state = state.copyWith(salary: item?.freeze());
  }

  /// Realm から Salary を取得
  void resetSalary() {
    state = state.copyWith(salary: null);
  }
}