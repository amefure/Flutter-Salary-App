import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/notify/notify_reminder_service.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:salary/feature/reminder/reminder_settings_state.dart';

final reminderSettingsProvider = StateNotifierProvider.autoDispose<
  ReminderSettingsViewModel,
  ReminderSettingsState
>((ref) {
  final userSettings = ref.read(userSettingsProvider);
  return ReminderSettingsViewModel(userSettings);
});

class ReminderSettingsViewModel extends StateNotifier<ReminderSettingsState> {
  final UserSettingsRepository _userSettings;

  ReminderSettingsViewModel(this._userSettings)
    : super(
        ReminderSettingsState(
          isReminderEnabled: _userSettings.fetchReminderEnabled(),
          reminderDay: _userSettings.fetchReminderDay(),
          reminderMessage: _userSettings.fetchReminderMessage(),
          reminderHour: _userSettings.fetchReminderHour(),
          reminderMinute: _userSettings.fetchReminderMinute(),
        ),
      );

  Future<void> toggleReminderEnabled(bool enabled) async {
    state = state.copyWith(isReminderEnabled: enabled);
    await _userSettings.saveReminderEnabled(enabled);
    await _rescheduleNotification(enabled: enabled);
  }

  Future<void> updateReminderDay(int day) async {
    state = state.copyWith(reminderDay: day);
    await _userSettings.saveReminderDay(day);
    await _rescheduleNotification();
  }

  Future<void> updateReminderMessage(String message) async {
    state = state.copyWith(reminderMessage: message);
    await _userSettings.saveReminderMessage(message);
    await _rescheduleNotification();
  }

  /// 通知時間の更新 ＋ 再スケジュール
  Future<void> updateReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await _userSettings.saveReminderHour(hour);
    await _userSettings.saveReminderMinute(minute);
    await _rescheduleNotification();
  }

  Future<void> _rescheduleNotification({bool? enabled}) async {
    final isEnabled = enabled ?? state.isReminderEnabled;
    await NotifyReminderService().scheduleMonthlyReminder(
      payDay: state.reminderDay,
      body: state.reminderMessage,
      hour: state.reminderHour,
      minute: state.reminderMinute,
      enabled: isEnabled,
    );
  }
}
