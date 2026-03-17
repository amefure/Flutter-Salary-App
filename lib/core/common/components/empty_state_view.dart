import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

class EmptyStateView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateView({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: CustomColors.foundation(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: CustomColors.themaGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          CustomText(
            text: message,
            textSize: TextSize.S,
            color: CustomColors.themaGray,
            fontWeight: FontWeight.w600,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}