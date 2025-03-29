import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/views/components/custom_text_view.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool readOnly;
  final Function()? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.number,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.circle, size: 15),

            SizedBox(width: 8),

            CustomText(
              text: labelText,
              textSize: TextSize.MS,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),

        SizedBox(height: 8),

        CupertinoTextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          placeholder: labelText,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(prefixIcon, color: CupertinoColors.systemGrey),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.white, // 背景色
            borderRadius: BorderRadius.circular(5), // 角丸
          ),
        ),
      ],
    );
  }
}
