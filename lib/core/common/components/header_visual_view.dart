import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

/// 上部のビジュアル部分
class HeaderVisualView extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? msg;
  const HeaderVisualView({
    super.key,
    required this.icon,
    this.title,
    this.msg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 背景の円形グラデーション
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CustomColors.themaOrange.withAlpha(50),
                      CustomColors.themaOrange.withAlpha(0),
                    ],
                  ),
                ),
              ),
              Icon(
                icon,
                size: 40,
                color: CustomColors.themaOrange,
              ),
            ],
          ),

          if (title != null) ...[
            const SizedBox(height: 24),
            CustomText(
              text: title!,
              textSize: TextSize.L,
              fontWeight: FontWeight.bold,
            ),
          ],
          if (msg != null) ...[
            const SizedBox(height: 8),
            CustomText(
              text: msg!,
              textSize: TextSize.S,
              color: CupertinoColors.systemGrey,
              maxLines: 3,
            ),
          ],
        ]);
  }
}