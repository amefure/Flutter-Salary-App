import 'package:salary/core/models/annual_target.dart';
import 'package:salary/core/models/salary.dart';

class AnnualTargetState {
  final List<AnnualTarget> targets;
  final List<Salary> salaries;
  final bool isSaving;

  const AnnualTargetState({
    required this.targets,
    required this.salaries,
    this.isSaving = false,
  });

  factory AnnualTargetState.initial() {
    return const AnnualTargetState(targets: [], salaries: []);
  }

  AnnualTargetState copyWith({
    List<AnnualTarget>? targets,
    List<Salary>? salaries,
    bool? isSaving,
  }) {
    return AnnualTargetState(
      targets: targets ?? this.targets,
      salaries: salaries ?? this.salaries,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}