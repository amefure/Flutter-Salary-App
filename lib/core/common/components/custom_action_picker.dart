import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

class CustomActionPicker {
  /// iOSデザインのアクションシート形式ピッカーを表示
  static void show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required T? currentValue,
    required String Function(T) labelBuilder,
    required void Function(T) onSelected,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: CustomText(
          text: title,
          textSize: TextSize.S,
          fontWeight: FontWeight.bold,
        ),
        actions: items.map((item) {
          final isSelected = (item == currentValue);

          return CupertinoActionSheetAction(
            onPressed: () {
              onSelected(item);
              Navigator.pop(context);
            },
            child: CustomText(
              text: labelBuilder(item),
              textSize: TextSize.M,
              color: isSelected ? CustomColors.themaBlue : CustomColors.text(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const CustomText(
            text: 'キャンセル',
            color: CustomColors.negative,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}