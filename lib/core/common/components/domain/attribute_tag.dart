import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';

class AttributeTag extends StatelessWidget {

  const AttributeTag({
    super.key,
    required this.text,
    required this.baseColor,
  });
  final String text;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: baseColor.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomText(
        text: text,
        textSize: TextSize.SSS,
        color: baseColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
