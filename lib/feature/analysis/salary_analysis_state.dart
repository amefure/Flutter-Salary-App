import 'package:salary/core/models/salary.dart';

class SalaryAnalysisState {
  final List<Salary> allSalaries;
  final List<String> availableItemNames;
  final String? selectedItemName;
  final String? baseSalaryId;
  final String? targetSalaryId;

  const SalaryAnalysisState({
    required this.allSalaries,
    required this.availableItemNames,
    this.selectedItemName,
    this.baseSalaryId,
    this.targetSalaryId,
  });

  factory SalaryAnalysisState.initial() {
    return const SalaryAnalysisState(
      allSalaries: [],
      availableItemNames: [],
      selectedItemName: null,
      baseSalaryId: null,
      targetSalaryId: null,
    );
  }

  SalaryAnalysisState copyWith({
    List<Salary>? allSalaries,
    List<String>? availableItemNames,
    String? selectedItemName,
    String? baseSalaryId,
    String? targetSalaryId,
  }) {
    return SalaryAnalysisState(
      allSalaries: allSalaries ?? this.allSalaries,
      availableItemNames: availableItemNames ?? this.availableItemNames,
      selectedItemName: selectedItemName ?? this.selectedItemName,
      baseSalaryId: baseSalaryId ?? this.baseSalaryId,
      targetSalaryId: targetSalaryId ?? this.targetSalaryId,
    );
  }
}