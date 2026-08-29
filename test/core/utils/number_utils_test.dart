import 'package:flutter_test/flutter_test.dart';
import 'package:salary/core/utils/number_utils.dart';

void main() {
  group('NumberUtils テスト', () {
    group('formatWithComma', () {
      test('通常の数値をカンマ区切りの文字列に変換できること', () {
        expect(NumberUtils.formatWithComma(1000), '1,000');
        expect(NumberUtils.formatWithComma(1234567), '1,234,567');
      });

      test('1000未満の数値はそのまま文字列に変換されること', () {
        expect(NumberUtils.formatWithComma(0), '0');
        expect(NumberUtils.formatWithComma(999), '999');
      });

      test('マイナスの数値も正しくカンマ区切りに変換されること', () {
        expect(NumberUtils.formatWithComma(-1000), '-1,000');
        expect(NumberUtils.formatWithComma(-123456), '-123,456');
      });
    });
  });
}