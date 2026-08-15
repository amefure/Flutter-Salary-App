import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/core/models/salary.dart';
import 'salary_analysis_state.dart';

final salaryAnalysisProvider =
StateNotifierProvider<SalaryAnalysisViewModel, SalaryAnalysisState>((ref) {
  final repository = ref.read(localSalaryRepositoryProvider);
  return SalaryAnalysisViewModel(repository);
});

class SalaryAnalysisViewModel extends StateNotifier<SalaryAnalysisState> {
  final LocalSalaryRepository _repository;

  SalaryAnalysisViewModel(this._repository) : super(SalaryAnalysisState.initial()) {
    _loadSalaries();
  }

  void _loadSalaries() {
    final salaries = _repository.fetchAll();
    salaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final itemNames = salaries
        .expand((s) => [...s.paymentAmountItems, ...s.deductionAmountItems])
        .map((item) => item.key)
        .toSet()
        .toList();

    String? initialBaseId;
    String? initialTargetId;

    if (salaries.length >= 2) {
      initialTargetId = salaries[0].id; // ※モデルにidプロパティがある前提 (ない場合はユニークなキー)
      initialBaseId = salaries[1].id;
    } else if (salaries.length == 1) {
      initialTargetId = salaries[0].id;
      initialBaseId = salaries[0].id;
    }

    state = state.copyWith(
      allSalaries: salaries,
      availableItemNames: itemNames,
      selectedItemName: itemNames.isNotEmpty ? itemNames.first : null,
      baseSalaryId: initialBaseId,
      targetSalaryId: initialTargetId,
    );
  }

  void updateBaseSalaryId(String id) {
    state = state.copyWith(baseSalaryId: id);
  }

  void updateTargetSalaryId(String id) {
    state = state.copyWith(targetSalaryId: id);
  }

  void selectItemName(String? name) {
    state = state.copyWith(selectedItemName: name);
  }

  // IDで給料データを完全に一意に取得する
  Salary? findSalaryById(String? id) {
    if (id == null) return null;
    try {
      return state.allSalaries.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, int> getFilteredItemHistory() {
    if (state.selectedItemName == null) return {};

    final Map<String, int> history = {};
    for (var salary in state.allSalaries) {
      final key = '${salary.createdAt.year}年${salary.createdAt.month}月';

      int totalValue = 0;
      for (var item in [...salary.paymentAmountItems, ...salary.deductionAmountItems]) {
        if (item.key == state.selectedItemName) {
          totalValue += item.value;
        }
      }
      if (totalValue > 0) {
        history[key] = totalValue;
      }
    }
    return history;
  }
}