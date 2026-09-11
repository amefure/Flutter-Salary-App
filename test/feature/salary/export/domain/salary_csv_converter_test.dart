import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:salary/feature/salary/export/domain/salary_csv_converter.dart';

import '../../../../helpers/dummy_data_helper.dart';

void main() {
  const converter = SalaryCsvConverter();

  group('SalaryCsvConverter', () {
    test('通常データをヘッダーとデータ行へ変換する', () {
      final salary = fakeSalary(
        date: DateTime(2026, 9, 1),
        paymentAmount: 300000,
        deductionAmount: 60000,
        netSalary: 240000,
        isBonus: true,
        memo: '通常のメモ',
        source: fakePaymentSource(name: '株式会社Ame'),
      );

      final csv = converter.convertToCsv([salary]);

      expect(
        csv,
        '"支払い日","総支給額","控除額","手取り額","支払い元名","ボーナス","メモ"\r\n'
        '"2026-09-01T00:00:00.000","300000","60000","240000","株式会社Ame","true","通常のメモ"',
      );
    });

    test('UTF-8 BOMを先頭に付与する', () {
      final bytes = converter.convertToUtf8Bom(const []);

      expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      expect(
        utf8.decode(bytes.sublist(3)),
        '"支払い日","総支給額","控除額","手取り額","支払い元名","ボーナス","メモ"',
      );
    });

    test('カンマ、改行、ダブルクォーテーションを1セルとしてエスケープする', () {
      final salary = fakeSalary(
        source: fakePaymentSource(name: '会社, "本社"\n支店'),
        memo: 'メモ1, メモ2\r\n"重要"',
      );

      final csv = converter.convertToCsv([salary]);

      expect(csv, contains('"会社, ""本社""\n支店","false","メモ1, メモ2\r\n""重要"""'));
      expect(csv.split(',').length, greaterThan(7));
      expect(csv, contains('"支払い元名"'));
    });
  });
}
