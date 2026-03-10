import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

/// フィルター用チップ
class CustomFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CustomFilterChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CustomColors.foundation(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CustomColors.themaBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CustomText(text: label, textSize: TextSize.SS, color: CustomColors.themaBlue, fontWeight: FontWeight.bold),
            const Icon(Icons.arrow_drop_down, color: CustomColors.themaBlue, size: 18),
          ],
        ),
      ),
    );
  }
}