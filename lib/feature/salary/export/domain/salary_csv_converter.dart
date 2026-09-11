import 'dart:convert';
import 'dart:typed_data';

import 'package:salary/core/models/salary.dart';

/// ローカルに保存された給料を、外部でも扱いやすいCSVへ変換する。
class SalaryCsvConverter {
  const SalaryCsvConverter();

  static const headers = <String>[
    '支払い日',
    '総支給額',
    '控除額',
    '手取り額',
    '支払い元名',
    'ボーナス',
    'メモ',
  ];

  /// UTF-8 BOMを含むCSVファイルのバイト列を返す。
  Uint8List convertToUtf8Bom(Iterable<Salary> salaries) {
    final csv = convertToCsv(salaries);
    return Uint8List.fromList(<int>[0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
  }

  /// RFC 4180相当のCSV文字列を返す。
  ///
  /// ヘッダーを含め、すべての値を引用することで、金額や文字列を
  /// 表計算ソフトで同じルールで扱えるようにする。
  String convertToCsv(Iterable<Salary> salaries) {
    final rows = <String>[
      _encodeRow(headers),
      ...salaries.map(
        (salary) => _encodeRow(<String>[
          salary.createdAt.toIso8601String(),
          salary.paymentAmount.toString(),
          salary.deductionAmount.toString(),
          salary.netSalary.toString(),
          salary.source?.name ?? '',
          salary.isBonus.toString(),
          salary.memo,
        ]),
      ),
    ];

    // RFC 4180に合わせて行末はCRLFにする。0件でもヘッダーだけを返す。
    return rows.join('\r\n');
  }

  String _encodeRow(Iterable<String> values) {
    return values.map(_encodeField).join(',');
  }

  String _encodeField(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }
}
