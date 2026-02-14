import 'package:flutter/cupertino.dart';
import 'package:salary/core/utils/custom_colors.dart';

/// iOSデザインのピッカーモーダル(ボトムシート表示)
class CupertinoPickerModal {

  static void show<T>({
    required BuildContext context,
    required List<T> items,
    required T currentValue,
    required String Function(T) labelBuilder,
    required void Function(T) onSelected,
  }) {

    final initialIndex = items.indexOf(currentValue);

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoPicker(
            itemExtent: 36,
            scrollController: FixedExtentScrollController(
              initialItem: initialIndex >= 0 ? initialIndex : 0,
            ),
            onSelectedItemChanged: (index) {
              onSelected(items[index]);
            },
            children: items
                .map((e) => Center(child: Text(labelBuilder(e))))
                .toList(),
          ),
        );
      },
    );
  }
}
