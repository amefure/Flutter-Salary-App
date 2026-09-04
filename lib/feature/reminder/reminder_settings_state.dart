class ReminderSettingsState {
  final bool isReminderEnabled;
  final int reminderDay;
  final String reminderMessage;
  final int reminderHour;
  final int reminderMinute;
  final bool isSaving;

  const ReminderSettingsState({
    required this.isReminderEnabled,
    required this.reminderDay,
    required this.reminderMessage,
    required this.reminderHour,
    required this.reminderMinute,
    this.isSaving = false,
  });

  ReminderSettingsState copyWith({
    bool? isReminderEnabled,
    int? reminderDay,
    String? reminderMessage,
    int? reminderHour,
    int? reminderMinute,
    bool? isSaving,
  }) {
    return ReminderSettingsState(
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderDay: reminderDay ?? this.reminderDay,
      reminderMessage: reminderMessage ?? this.reminderMessage,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
