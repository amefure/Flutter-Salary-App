import 'package:salary/core/models/salary.dart';
import 'domain/salary_analysis_models.dart';

class SalaryAnalysisState {
  final List<Salary> allSalaries;
  final List<String> availableItemNames;
  final List<PaymentSource> availableSources;
  final List<SalarySourceFilter> sourceFilters;
  final SalarySourceFilter selectedSourceFilter;
  final SalarySummary summary;
  final String? selectedItemName;
  final String? baseSalaryId;
  final String? targetSalaryId;
  final int selectedYear;

  const SalaryAnalysisState({
    required this.allSalaries,
    required this.availableItemNames,
    required this.availableSources,
    required this.sourceFilters,
    required this.selectedSourceFilter,
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
      sourceFilters: const [SalarySourceFilter.all()],
      selectedSourceFilter: const SalarySourceFilter.all(),
      summary: const SalarySummary(
        grossRanking: [],
        netRanking: [],
        grossTotal: 0,
        netTotal: 0,
        averageMonthlyGross: 0,
        averageMonthlyNet: 0,
        monthCount: 0,
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
    List<SalarySourceFilter>? sourceFilters,
    SalarySourceFilter? selectedSourceFilter,
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
      sourceFilters: sourceFilters ?? this.sourceFilters,
      selectedSourceFilter: selectedSourceFilter ?? this.selectedSourceFilter,
      summary: summary ?? this.summary,
      selectedItemName: selectedItemName ?? this.selectedItemName,
      baseSalaryId: baseSalaryId ?? this.baseSalaryId,
      targetSalaryId: targetSalaryId ?? this.targetSalaryId,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}
