import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/feature/salary/data/salary_repository_impl.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_state.dart';
import 'package:salary/feature/salary/domain/salary_repository.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

final detailSalaryProvider =
StateNotifierProvider.autoDispose.family<DetailSalaryViewModel, DetailSalaryState, String>(
      (ref, id) {
    final repository = RealmRepository();
    final salaryRepository = ref.read(salaryRepositoryProvider);
    return DetailSalaryViewModel(ref, repository, salaryRepository)..loadSalary(id);
  },
);

class DetailSalaryViewModel extends StateNotifier<DetailSalaryState> {
  final Ref _ref;

  final RealmRepository _repository;
  final SalaryRepository _salaryRepository;

  /// 初期インスタンス化
  DetailSalaryViewModel(this._ref, this._repository, this._salaryRepository)
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
  Future<bool> delete(Salary salary) async {
    if (salary.source?.isPublic == true) {
      return await _ref.runWithGlobalHandling(() async {
        // クラウド登録
        await _salaryRepository.delete(salaries: [salary]);
        // 削除前にnullにして画面を更新
        _resetSalary();
        // 削除処理
        _repository.deleteById<Salary>(salary.id);
        // MyData画面のリフレッシュ
        _ref.read(chartSalaryProvider.notifier).refresh();
        // Homeリスト画面のリフレッシュ
        _ref.read(listSalaryProvider.notifier).refresh();
      });
    } else {
      // 削除前にnullにして画面を更新
      _resetSalary();
      // 削除処理
      _repository.deleteById<Salary>(salary.id);
      // MyData画面のリフレッシュ
      _ref.read(chartSalaryProvider.notifier).refresh();
      // Homeリスト画面のリフレッシュ
      _ref.read(listSalaryProvider.notifier).refresh();
    }
    return true;
  }
}