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

    // 全ての支給・控除項目名を取得
    final paymentNames = salaries.expand((s) => s.paymentAmountItems).map((i) => i.key).toSet();
    final deductionNames = salaries.expand((s) => s.deductionAmountItems).map((i) => i.key).toSet();

    final itemNames = [...paymentNames, ...deductionNames].toSet().toList();

    String? initialBaseId;
    String? initialTargetId;

    if (salaries.length >= 2) {
      initialTargetId = salaries[0].id;
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

  /// 支給項目名のリスト（ViewModelで保持・提供）
  List<String> get paymentItemNames {
    final paymentNames = state.allSalaries.expand((s) => s.paymentAmountItems).map((i) => i.key).toSet();
    return state.availableItemNames.where((name) => paymentNames.contains(name)).toList();
  }

  /// 控除項目名のリスト（ViewModelで保持・提供）
  List<String> get deductionItemNames {
    final deductionNames = state.allSalaries.expand((s) => s.deductionAmountItems).map((i) => i.key).toSet();
    return state.availableItemNames.where((name) => deductionNames.contains(name)).toList();
  }

  /// 指定した項目名が控除項目かどうかを判定
  bool isItemDeduction(String itemName) {
    for (var salary in state.allSalaries) {
      if (salary.deductionAmountItems.any((i) => i.key == itemName)) {
        return true;
      }
    }
    return false;
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

  Salary? findSalaryById(String? id) {
    if (id == null) return null;
    try {
      return state.allSalaries.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  double calculateMaxY(Iterable<double> values) {
    if (values.isEmpty) return 10000;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max == 0) return 10000;
    return max * 1.2;
  }

  void changeYear(int delta) {
    final newYear = state.selectedYear + delta;
    state = state.copyWith(selectedYear: newYear);
  }

  /// 選択された項目が「控除項目」かどうかを判定する
  bool get isSelectedItemSelectedAsDeduction {
    if (state.selectedItemName == null) return false;
    return isItemDeduction(state.selectedItemName!);
  }

  /// 選択された年・項目の12ヶ月分の推移データを取得
  List<double> getMonthlyDataForYear() {
    final monthlyData = List.generate(12, (_) => 0.0);

    if (state.selectedItemName == null) return monthlyData;

    for (var salary in state.allSalaries) {
      if (salary.createdAt.year == state.selectedYear) {
        final monthIndex = salary.createdAt.month - 1; // 0-11
        if (monthIndex < 0 || monthIndex >= 12) continue;

        // 支給か控除かによって参照先を明確に分ける
        final targetItems = isSelectedItemSelectedAsDeduction
            ? salary.deductionAmountItems
            : salary.paymentAmountItems;

        final item = targetItems.firstWhere(
              (i) => i.key == state.selectedItemName,
          orElse: () => AmountItem('id', '', 0),
        );

        monthlyData[monthIndex] += item.value.toDouble();
      }
    }
    return monthlyData;
  }
}