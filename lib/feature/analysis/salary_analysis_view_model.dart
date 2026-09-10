import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/feature/analysis/domain/salary_analysis_calculator.dart';
import 'salary_analysis_state.dart';

final salaryAnalysisProvider =
StateNotifierProvider<SalaryAnalysisViewModel, SalaryAnalysisState>((ref) {
  final repository = ref.read(localSalaryRepositoryProvider);
  return SalaryAnalysisViewModel(repository);
});

class SalaryAnalysisViewModel extends StateNotifier<SalaryAnalysisState> {
  final LocalSalaryRepository _repository;
  final SalaryAnalysisCalculator _calculator;

  SalaryAnalysisViewModel(
      this._repository, {
        SalaryAnalysisCalculator calculator = const SalaryAnalysisCalculator(),
      }) : _calculator = calculator,
        super(SalaryAnalysisState.initial()) {
    _loadSalaries();
  }

  void refresh() {
    _loadSalaries();
  }

  /// データを再読み込み・リフレッシュする
  void _loadSalaries() {
    final salaries = _repository.fetchAll();
    salaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 全ての支給・控除項目名を取得
    final paymentNames =
    salaries.expand((s) => s.paymentAmountItems).map((i) => i.key).toSet();
    final deductionNames =
    salaries
        .expand((s) => s.deductionAmountItems)
        .map((i) => i.key)
        .toSet();

    final itemNames = {...paymentNames, ...deductionNames}.toList();
    final sourcesById = <String, PaymentSource>{};
    for (final salary in salaries) {
      final source = salary.source;
      if (source != null) {
        sourcesById[source.id] = source;
      }
    }
    final sources = [...sourcesById.values]
      ..sort((a, b) => a.name.compareTo(b.name));

    // 先頭に「すべて」を表す DummySource.allDummySource を配置
    final sourceList = [
      DummySource.allDummySource,
      ...sources,
    ];

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
      availableSources: sources,
      sourceList: sourceList,
      selectedSource: DummySource.allDummySource,
      summary: _calculator.summarize(salaries, selectedSource: DummySource.allDummySource),
      selectedItemName: itemNames.isNotEmpty ? itemNames.first : null,
      baseSalaryId: initialBaseId,
      targetSalaryId: initialTargetId,
    );
  }

  List<String> get paymentItemNames {
    final paymentNames =
    state.allSalaries
        .expand((s) => s.paymentAmountItems)
        .map((i) => i.key)
        .toSet();
    return state.availableItemNames
        .where((name) => paymentNames.contains(name))
        .toList();
  }

  List<String> get deductionItemNames {
    final deductionNames =
    state.allSalaries
        .expand((s) => s.deductionAmountItems)
        .map((i) => i.key)
        .toSet();
    return state.availableItemNames
        .where((name) => deductionNames.contains(name))
        .toList();
  }

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

  /// PaymentSource で絞り込みを更新
  void selectSource(PaymentSource source) {
    state = state.copyWith(
      selectedSource: source,
      summary: _calculator.summarize(state.allSalaries, selectedSource: source),
    );
  }

  String sourceNameForId(String? sourceId) {
    if (sourceId == null) return '未設定';
    for (final source in state.availableSources) {
      if (source.id == sourceId) return source.name;
    }
    return sourceId;
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

  bool get isSelectedItemSelectedAsDeduction {
    if (state.selectedItemName == null) return false;
    return isItemDeduction(state.selectedItemName!);
  }

  List<double> getMonthlyDataForYear() {
    final monthlyData = List.generate(12, (_) => 0.0);

    if (state.selectedItemName == null) return monthlyData;

    for (var salary in state.allSalaries) {
      if (salary.createdAt.year == state.selectedYear) {
        final monthIndex = salary.createdAt.month - 1;
        if (monthIndex < 0 || monthIndex >= 12) continue;

        final targetItems =
        isSelectedItemSelectedAsDeduction
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