import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/annual_target.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/domain/local_annual_target_repository.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/annual_target/annual_target_state.dart';

final annualTargetProvider =
StateNotifierProvider<AnnualTargetViewModel, AnnualTargetState>((ref) {
  return AnnualTargetViewModel(
    ref.read(localAnnualTargetRepositoryProvider),
    ref.read(localSalaryRepositoryProvider),
  );
});

class AnnualTargetViewModel extends StateNotifier<AnnualTargetState> {
  final LocalAnnualTargetRepository _localAnnualTargetRepository;
  final LocalSalaryRepository _localSalaryRepository;

  AnnualTargetViewModel(
      this._localAnnualTargetRepository,
      this._localSalaryRepository,
      ) : super(AnnualTargetState.initial()) {
    fetchAll();
  }

  void fetchAll() {
    final targets = _localAnnualTargetRepository.fetchAll();
    // 指定された形式で給料データを取得
    final salaries = _localSalaryRepository.fetchAllSortCreatedAt(isMock: false);

    state = state.copyWith(
      targets: targets,
      salaries: salaries,
    );
  }

  /// 指定した年の実績（総支給）を計算する
  int getActualAmountForYear(int year) {
    return state.salaries
        .where((s) => s.createdAt.year == year)
        .fold(0, (sum, s) => sum + s.paymentAmount);
  }

  /// 入力値を検証して保存・更新する。成功したらtrueを返す。
  bool saveTarget({required int year, required int targetAmount}) {
    if (year <= 0 || targetAmount <= 0) {
      return false;
    }

    state = state.copyWith(isSaving: true);
    _localAnnualTargetRepository.save(year: year, targetAmount: targetAmount);

    // データを再取得して状態を更新
    fetchAll();

    state = state.copyWith(isSaving: false);
    return true;
  }

  AnnualTarget? targetForYear(int year) {
    for (final target in state.targets) {
      if (target.year == year) return target;
    }
    return null;
  }
}