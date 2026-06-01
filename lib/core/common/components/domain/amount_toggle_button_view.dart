import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';

/// 金額テキストフィールドの suffix に指定するプラス・マイナス切り替えボタン
class AmountToggleButtonView extends StatefulWidget {
  const AmountToggleButtonView({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<AmountToggleButtonView> createState() => _AmountToggleButtonViewState();
}

class _AmountToggleButtonViewState extends State<AmountToggleButtonView> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleAmountSign() {
    final text = widget.controller.text.trim();
    if (text.isEmpty || text == '0' || text == '-') return;
    setState(() {
      String newText = text.startsWith('-') ? text.substring(1) : '-$text';
      widget.controller.text = newText;

      // カーソル位置を末尾に固定
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMinus = widget.controller.text.startsWith('-');

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        minimumSize: const Size(30, 15),
        color: isMinus
            ? CupertinoColors.systemRed.withAlpha(40)
            : CupertinoColors.activeBlue.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
        onPressed: _toggleAmountSign,
        child: CustomText(
          text: isMinus ? '－' : '＋',
          color: isMinus ? CupertinoColors.systemRed : CupertinoColors.activeBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}