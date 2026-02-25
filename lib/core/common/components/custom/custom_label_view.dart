import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';

class CustomLabelView extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final double size;

  const CustomLabelView({
    super.key,
    required this.labelText,
    this.icon = CupertinoIcons.circle,
    this.size = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: size),

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
