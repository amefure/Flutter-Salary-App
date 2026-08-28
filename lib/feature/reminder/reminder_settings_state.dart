class ReminderSettingsState {
  final int reminderDay;
  final String reminderMessage;
  final int reminderHour;
  final int reminderMinute;
  final bool isSaving;

  const ReminderSettingsState({
    required this.reminderDay,
    required this.reminderMessage,
    required this.reminderHour,
    required this.reminderMinute,
    this.isSaving = false,
  });

  ReminderSettingsState copyWith({
    int? reminderDay,
    String? reminderMessage,
    int? reminderHour,
    int? reminderMinute,
    bool? isSaving,
  }) {
    return ReminderSettingsState(
      reminderDay: reminderDay ?? this.reminderDay,
      reminderMessage: reminderMessage ?? this.reminderMessage,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}