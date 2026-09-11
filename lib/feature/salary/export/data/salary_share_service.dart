import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:salary/feature/salary/export/domain/salary_export_labels.dart';

abstract interface class SalaryShareService {
  Future<void> share(
    Uint8List bytes, {
    required String fileName,
    Rect? sharePositionOrigin,
  });
}

/// OSの共有シートを使ってCSVファイルを共有する実装。
class SharePlusSalaryShareService implements SalaryShareService {
  const SharePlusSalaryShareService();

  @override
  Future<void> share(
    Uint8List bytes, {
    required String fileName,
    Rect? sharePositionOrigin,
  }) async {
    final temporaryDirectory = await getTemporaryDirectory();
    final file = File('${temporaryDirectory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path, mimeType: 'text/csv')],
          subject: SalaryExportLabels.fileSubject,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } finally {
      // 共有処理が完了してから一時ファイルを削除する。
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
