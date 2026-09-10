import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'domain/salary_analysis_models.dart';

class SalaryAnalysisState {
  final List<Salary> allSalaries;
  final List<String> availableItemNames;
  final List<PaymentSource> availableSources;
  final List<PaymentSource> sourceList;
  final PaymentSource selectedSource;
  final SalarySummary summary;
  final String? selectedItemName;
  final String? baseSalaryId;
  final String? targetSalaryId;
  final int selectedYear;

  const SalaryAnalysisState({
    required this.allSalaries,
    required this.availableItemNames,
    required this.availableSources,
    required this.sourceList,
    required this.selectedSource,
    required this.summary,
    this.selectedItemName,
    this.baseSalaryId,
    this.targetSalaryId,
    required this.selectedYear,
  });

  factory SalaryAnalysisState.initial() {
    int year = DateTime.now().year;
    return SalaryAnalysisState(
      allSalaries: const [],
      availableItemNames: const [],
      availableSources: const [],
      sourceList: [DummySource.allDummySource],
      selectedSource: DummySource.allDummySource,
      summary: const SalarySummary(
        grossRanking: [],
        netRanking: [],
        grossTotal: 0,
        netTotal: 0,
        averageMonthlyGross: 0,
        averageMonthlyNet: 0,
        monthCount: 0,
        averageYearlyGross: 0,
        averageYearlyNet: 0,
        yearCount: 0,
        bonusTotal: 0
      ),
      selectedItemName: null,
      baseSalaryId: null,
      targetSalaryId: null,
      selectedYear: year,
    );
  }

  SalaryAnalysisState copyWith({
    List<Salary>? allSalaries,
    List<String>? availableItemNames,
    List<PaymentSource>? availableSources,
    List<PaymentSource>? sourceList,
    PaymentSource? selectedSource,
    SalarySummary? summary,
    String? selectedItemName,
    String? baseSalaryId,
    String? targetSalaryId,
    int? selectedYear,
  }) {
    return SalaryAnalysisState(
      allSalaries: allSalaries ?? this.allSalaries,
      availableItemNames: availableItemNames ?? this.availableItemNames,
      availableSources: availableSources ?? this.availableSources,
      sourceList: sourceList ?? this.sourceList,
      selectedSource: selectedSource ?? this.selectedSource,
      summary: summary ?? this.summary,
      selectedItemName: selectedItemName ?? this.selectedItemName,
      baseSalaryId: baseSalaryId ?? this.baseSalaryId,
      targetSalaryId: targetSalaryId ?? this.targetSalaryId,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}