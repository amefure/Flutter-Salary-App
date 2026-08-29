import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils テスト', () {
    group('isValidEmail', () {
      test('正しい形式のメールアドレスの場合は true を返すこと', () {
        expect(ValidationUtils.isValidEmail('test@example.com'), isTrue);
        expect(ValidationUtils.isValidEmail('user.name@sub.domain.co.jp'), isTrue);
        expect(ValidationUtils.isValidEmail('a_b-c@example.org'), isTrue);
      });

      test('不正な形式のメールアドレスの場合は false を返すこと', () {
        expect(ValidationUtils.isValidEmail(''), isFalse); // 空文字
        expect(ValidationUtils.isValidEmail('testexample.com'), isFalse); // @なし
        expect(ValidationUtils.isValidEmail('test@example'), isFalse); // ドメインのトップレベルなし
        expect(ValidationUtils.isValidEmail('test@.com'), isFalse); // ドメイン名なし
        expect(ValidationUtils.isValidEmail(' test@example.com'), isFalse); // 先頭に空白
        expect(ValidationUtils.isValidEmail('test@example.com '), isFalse); // 末尾に空白
      });
    });

    group('isValidPassword', () {
      test('8文字以上で英数字が混在している場合は true を返すこと', () {
        expect(ValidationUtils.isValidPassword('password123'), isTrue);
        expect(ValidationUtils.isValidPassword('Abcdefg1'), isTrue);
        expect(ValidationUtils.isValidPassword('12345678a'), isTrue);
      });

      test('8文字未満の場合は false を返すこと', () {
        expect(ValidationUtils.isValidPassword(''), isFalse);
        expect(ValidationUtils.isValidPassword('abc1234'), isFalse); // 7文字
      });

      test('英字または数字のどちらか一方が欠けている場合は false を返すこと', () {
        expect(ValidationUtils.isValidPassword('abcdefgh'), isFalse); // 数字なし（8文字）
        expect(ValidationUtils.isValidPassword('12345678'), isFalse); // 英字なし（8文字）
      });
    });
  });
}