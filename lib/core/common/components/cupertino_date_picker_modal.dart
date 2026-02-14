import 'package:flutter/cupertino.dart';
import 'package:salary/core/utils/custom_colors.dart';

class CupertinoDatePickerModal {

  static void show({
    required BuildContext context,
    required DateTime initialDate,
    required void Function(DateTime) onSelected,

    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
    DateTime? minimumDate,
    DateTime? maximumDate,
    int minimumYear = 1900,
    int? maximumYear,
  }) {

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoDatePicker(
            mode: mode,
            initialDateTime: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate ?? DateTime.now(),
            minimumYear: minimumYear,
            maximumYear: maximumYear,
            onDateTimeChanged: onSelected,
          ),
        );
      },
    );
  }
}
