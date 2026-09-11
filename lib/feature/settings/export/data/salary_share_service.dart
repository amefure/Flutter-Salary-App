import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/settings/export/domain/salary_export_labels.dart';
import 'package:share_plus/share_plus.dart';

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
    // デバッグ機能(CSV出力)
    if (kDebugMode) {
      try {
        final csvContent = utf8.decode(bytes);
        logger('========== CSV Export Preview ==========');
        logger(csvContent);
        logger('========================================');
      } catch (e) {
        logger('CSV log decode error: $e');
      }
    }

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
