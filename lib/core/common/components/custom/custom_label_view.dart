import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

class CustomLabelView extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final double size;
  final Color iconColor;

  const CustomLabelView({
    super.key,
    required this.labelText,
    this.icon = CupertinoIcons.circle,
    this.size = 15,
    this.iconColor = CustomColors.thema,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: size, color: iconColor),

        const SizedBox(width: 8),

        CustomText(
          text: labelText,
          textSize: TextSize.MS,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
