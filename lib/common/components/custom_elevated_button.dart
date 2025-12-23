import 'package:flutter/material.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/common/components/custom_text_view.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.backgroundColor = CustomColors.thema,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 5, // 影の濃さ
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: CustomText(
        text: text,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
