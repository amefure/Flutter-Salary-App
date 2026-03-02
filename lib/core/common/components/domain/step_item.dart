import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

class StepItem extends StatelessWidget {
  const StepItem({
    required this.number,
    required this.title,
    required this.isCompleted,
    this.onTap,
  });

  final int number;
  final String title;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isClickable = !isCompleted;

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isCompleted
              ? CustomColors.themaBlue.withAlpha(20)
              : isClickable
              ? CustomColors.themaOrange.withAlpha(20)
              : CupertinoColors.systemGrey6,
          border: isClickable
              ? Border.all(
            color: CustomColors.themaBlue.withAlpha(3),
          )
              : null,
        ),
        child: Row(
          children: [

            /// 丸アイコン
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? CustomColors.themaBlue
                    : CustomColors.themaBlack,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                  CupertinoIcons.check_mark,
                  size: 16,
                  color: CupertinoColors.white,
                )
                    : CustomText(
                  text: number.toString(),
                  textSize: TextSize.S,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// タイトル
            Expanded(
              child: CustomText(
                text: title,
                textSize: TextSize.S,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                color: CustomColors.text(context),
              ),
            ),

            /// 右側UI
            if (isCompleted)
              const CustomText(
                text: '完了',
                textSize: TextSize.S,
                fontWeight: FontWeight.w600,
                color: CustomColors.themaBlue,
              )
            else if (isClickable && onTap != null)
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 18,
                color: CupertinoColors.systemGrey,
              ),
          ],
        ),
      ),
    );
  }
}
