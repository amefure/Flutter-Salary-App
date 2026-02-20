import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

enum DialogType {
  success('成功'),
  error('Error'),
  confirm('確認');

  final String defaultTitle;
  const DialogType(this.defaultTitle);
}

class AppDialog {

  /// Confirmの場合は結果をboolで返す
  static Future<bool?> show({
    required BuildContext context,
    required String message,
    required DialogType type,
    String? title,
    String? positiveTitle,
    bool isPositiveNegativeType = false,
  }) {

    return showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {

        final actions = <Widget>[
          if (type == DialogType.confirm)
            CupertinoDialogAction(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.pop(dialogContext, false),
            ),

          CupertinoDialogAction(
            isDestructiveAction: type == DialogType.error,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: CustomText(
              text: positiveTitle ?? 'OK',
              fontWeight: FontWeight.bold,
              color: isPositiveNegativeType ? CustomColors.negative : CustomColors.thema,
              textSize: TextSize.MS
            ),
          ),
        ];

        return CupertinoAlertDialog(
          title: Text(title ?? type.defaultTitle),
          content: Text(message),
          actions: actions,
        );
      },
    );
  }
}
