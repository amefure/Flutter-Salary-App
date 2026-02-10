
class SettingState {
  /// アプリロックが有効かどうか
  final bool isAppLockEnabled;

  const SettingState({
    this.isAppLockEnabled = false,
  });

  SettingState copyWith({
    bool? isAppLockEnabled
  }) {
    return SettingState(
        isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled
    );
  }
}