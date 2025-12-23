import 'package:flutter/cupertino.dart';
import 'package:salary/common/components/custom_text_view.dart';

class CustomLabelView extends StatelessWidget {
  final String labelText;

  const CustomLabelView({super.key, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(CupertinoIcons.circle, size: 15),

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
