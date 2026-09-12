import 'package:salary/core/models/annual_target.dart';

class AnnualTargetState {
  final List<AnnualTarget> targets;
  final bool isSaving;

  const AnnualTargetState({required this.targets, this.isSaving = false});

  factory AnnualTargetState.initial() {
    return const AnnualTargetState(targets: []);
  }

  AnnualTargetState copyWith({List<AnnualTarget>? targets, bool? isSaving}) {
    return AnnualTargetState(
      targets: targets ?? this.targets,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
