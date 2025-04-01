import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/views/components/custom_label_view.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final TextInputType keyboardType;
  final bool readOnly;
  final int? maxLines;
  final Function()? onTap;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.prefixIconColor = CupertinoColors.systemGrey,
    this.keyboardType = TextInputType.number,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabelView(labelText: labelText),

        const SizedBox(height: 8),

        CupertinoTextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onSubmitted: onSubmitted,
          maxLines: maxLines,
          placeholder: labelText,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(prefixIcon, color: prefixIconColor),
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
