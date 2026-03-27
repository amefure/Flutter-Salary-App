
abstract class ValidationUtils {
  /// 空でない
  ///  @ と . を含む（正規表現）
  ///  先頭・末尾に空白がない
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );
    return emailRegExp.hasMatch(email);
  }

  /// 空でない
  /// 8文字以上
  /// 英数字混在（最低限）
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    return hasLetter && hasNumber;
  }
}