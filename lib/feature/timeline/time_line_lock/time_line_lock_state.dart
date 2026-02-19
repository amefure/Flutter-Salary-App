class TimeLineLockState {
  final bool isPublic;

  TimeLineLockState({
    required this.isPublic
  });

  TimeLineLockState initial() {
    return TimeLineLockState(
        isPublic: false
    );
  }

  TimeLineLockState copyWith(
      bool? isPublic
      ) {
    return TimeLineLockState(
        isPublic: isPublic ?? this.isPublic
    );
  }
}