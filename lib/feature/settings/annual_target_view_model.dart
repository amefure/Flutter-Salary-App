import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/annual_target.dart';
import 'package:salary/core/repository/domain/local_annual_target_repository.dart';
import 'package:salary/feature/settings/annual_target_state.dart';

final annualTargetProvider =
    StateNotifierProvider<AnnualTargetViewModel, AnnualTargetState>((ref) {
      return AnnualTargetViewModel(
        ref.read(localAnnualTargetRepositoryProvider),
      );
    });

class AnnualTargetViewModel extends StateNotifier<AnnualTargetState> {
  final LocalAnnualTargetRepository _repository;

  AnnualTargetViewModel(this._repository) : super(AnnualTargetState.initial()) {
    fetchAll();
  }

  void fetchAll() {
    state = state.copyWith(targets: _repository.fetchAll());
  }

  /// 入力値を検証して保存する。保存できない場合はfalseを返す。
  bool saveTarget({required int year, required int targetAmount}) {
    if (year <= 0 || targetAmount <= 0) {
      return false;
    }

    state = state.copyWith(isSaving: true);
    _repository.save(year: year, targetAmount: targetAmount);
    state = state.copyWith(targets: _repository.fetchAll(), isSaving: false);
    return true;
  }

  AnnualTarget? targetForYear(int year) {
    for (final target in state.targets) {
      if (target.year == year) return target;
    }
    return null;
  }
}
