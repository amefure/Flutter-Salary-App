
class AppLockSettingState {
  /// 入力されるパスワード
  List<String> inputPassword;
  /// 生体認証が有効かどうか
  bool isBiometricsAvailable;
  /// 認証成功
  bool isAuthenticated;
  /// 認証失敗
  bool isFailed;

  static const int passwordLength = 4;

  /// パスワード4桁入力済みかどうか
  bool get isInputComplete => inputPassword.length == passwordLength;

  AppLockSettingState({
    required this.inputPassword,
    required this.isBiometricsAvailable,
    required this.isAuthenticated,
    required this.isFailed,
  });

  static AppLockSettingState initial() {
    return AppLockSettingState(
        inputPassword: List.empty(),
        isBiometricsAvailable: false,
        isAuthenticated: false,
        isFailed: false
    );
  }

  AppLockSettingState copyWith({
    List<String>? inputPassword,
    bool? isBiometricsAvailable,
    bool? isAuthenticated,
    bool? isFailed,
  }) {
    return AppLockSettingState(
      inputPassword: inputPassword ?? this.inputPassword,
      isBiometricsAvailable: isBiometricsAvailable ?? this.isBiometricsAvailable,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isFailed: isFailed ?? this.isFailed,
    );
  }

}