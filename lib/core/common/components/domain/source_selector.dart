import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

/// 給与の支払い元を選択する汎用的なウィジェット（特定のProviderに依存しない）
class SourceSelector<T> extends StatelessWidget {
  final T? selectedSource;
  final List<T> sourceList;
  final String Function(T?) sourceName;
  final Widget Function(T?) buildLabelView;
  final Widget Function(T) buildIconView;
  final ValueChanged<T?> onChanged;

  const SourceSelector({
    super.key,
    required this.selectedSource,
    required this.sourceList,
    required this.sourceName,
    required this.buildLabelView,
    required this.buildIconView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得
    final screen = MediaQuery.of(context).size;
    return SizedBox(
        width: screen.width * 0.5,
        child: MenuAnchor(
      builder: (_, controller, __) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: buildLabelView(selectedSource),
        );
      },
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((_) {
          return CustomColors.background(context);
        }),
      ),
      menuChildren: sourceList.map((source) {
        final isSelected = selectedSource == source;
        return MenuItemButton(
          onPressed: () => onChanged(source),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((_) {
              return CustomColors.background(context);
            }),
          ),
          child: SizedBox(
            width: 200,
            child: Row(
              children: [
                buildIconView(source),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: sourceName(source),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSelected)
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CustomColors.text(context),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    ) );
  }
}