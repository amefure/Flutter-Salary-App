import 'package:flutter/cupertino.dart';
import 'package:salary/views/components/custom_label_view.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final TextInputType keyboardType;
  final bool readOnly;
  final int? maxLines;
  final Function()? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFocusLost;

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
    this.onFocusLost,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // フォーカスが外れたらコールバック実行
        widget.onFocusLost?.call();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabelView(labelText: widget.labelText),
        const SizedBox(height: 8),
        CupertinoTextField(
          focusNode: _focusNode,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onSubmitted: widget.onSubmitted,
          maxLines: widget.maxLines,
          placeholder: widget.labelText,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(widget.prefixIcon, color: widget.prefixIconColor),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}
