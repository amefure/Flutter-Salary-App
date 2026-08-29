import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:salary/core/utils/date_time_utils.dart';

void main() {
  // テスト実行前にロケールデータを初期化する
  setUpAll(() async {
    await initializeDateFormatting('ja_JP', null);
  });

  group('DateTimeUtils テスト', () {
    group('format', () {
      test('デフォルトパターン（yyyy年M月）で正しく文字列に変換されること', () {
        final dateTime = DateTime(2026, 8, 29);
        final result = DateTimeUtils.format(dateTime: dateTime);
        expect(result, '2026年8月');
      });

      test('カスタムパターンを指定して正しく文字列に変換されること', () {
        final dateTime = DateTime(2026, 8, 29, 12, 34);
        final result = DateTimeUtils.format(dateTime: dateTime, pattern: 'yyyy/MM/dd HH:mm');
        expect(result, '2026/08/29 12:34');
      });
    });

    group('parse', () {
      test('デフォルトパターン（yyyy年M月）の文字列を DateTime に変換できること', () {
        final result = DateTimeUtils.parse(dateString: '2026年8月');
        expect(result, isNotNull);
        expect(result?.year, 2026);
        expect(result?.month, 8);
      });

      test('カスタムパターンの文字列を DateTime に変換できること', () {
        final result = DateTimeUtils.parse(dateString: '2026/08/29', pattern: 'yyyy/MM/dd');
        expect(result, isNotNull);
        expect(result?.year, 2026);
        expect(result?.month, 8);
        expect(result?.day, 29);
      });

      test('パースできない不正な文字列の場合は null を返すこと', () {
        final result = DateTimeUtils.parse(dateString: 'invalid_date');
        expect(result, isNull);
      });

      test('フォーマットが一致しない文字列の場合は null を返すこと', () {
        // パターンは 'yyyy年M月' だが '2026-08' が渡された場合
        final result = DateTimeUtils.parse(dateString: '2026-08');
        expect(result, isNull);
      });
    });
  });
}