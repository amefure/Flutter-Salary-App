import 'package:salary/core/models/salary.dart';

class SalaryAnalysisState {
  final List<Salary> allSalaries;
  final List<String> availableItemNames;
  final String? selectedItemName;
  final String? baseSalaryId;
  final String? targetSalaryId;
  final int selectedYear;

  const SalaryAnalysisState({
    required this.allSalaries,
    required this.availableItemNames,
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
      selectedItemName: null,
      baseSalaryId: null,
      targetSalaryId: null,
      selectedYear: year,
    );
  }

  SalaryAnalysisState copyWith({
    List<Salary>? allSalaries,
    List<String>? availableItemNames,
    String? selectedItemName,
    String? baseSalaryId,
    String? targetSalaryId,
    int? selectedYear,
  }) {
    return SalaryAnalysisState(
      allSalaries: allSalaries ?? this.allSalaries,
      availableItemNames: availableItemNames ?? this.availableItemNames,
      selectedItemName: selectedItemName ?? this.selectedItemName,
      baseSalaryId: baseSalaryId ?? this.baseSalaryId,
      targetSalaryId: targetSalaryId ?? this.targetSalaryId,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}