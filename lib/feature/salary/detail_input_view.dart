import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:salary/core/common/components/custom_action_picker.dart';
import 'package:salary/core/common/components/domain/amount_toggle_button_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';

/// 金額詳細項目画面
/// Navigator経由でデータを受渡する
class DetailInputView extends StatefulWidget {
  const DetailInputView({
    super.key,
    required this.title,
    this.amountItem,
    this.pastItemNames = const [],
  });

  final String title;
  final AmountItem? amountItem;
  final List<String> pastItemNames;

  @override
  State<DetailInputView> createState() => _DetailInputViewState();
}

class _DetailInputViewState extends State<DetailInputView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.amountItem case AmountItem amountItem) {
      _nameController.text = amountItem.key;
      _amountController.text = amountItem.value.toString();
    }
  }

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context, String title) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const CustomText(
            text: 'ERROR',
            fontWeight: FontWeight.bold,
          ),
          content: CustomText(
            text: title,
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const CustomText(
                text: 'OK',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  void _registerAmountItem() {
    String name = _nameController.text;
    final int? amount = int.tryParse(_amountController.text);

    if (_amountController.text.length > 19) {
      _showErrorDialog(context, '19桁以上は入力できません。');
      return;
    }

    if (name.isEmpty || amount == null) {
      _showErrorDialog(context, '項目名と金額を正しく入力してください。');
      return;
    }

    if (widget.amountItem case AmountItem amountItem) {
      Navigator.of(
        context,
      ).pop(AmountItem(amountItem.id, name, amount));
    } else {
      Navigator.of(
        context,
      ).pop(AmountItem(Uuid.v4().toString(), name, amount));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: CustomColors.foundation(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation(context),
        navigationBar: CupertinoNavigationBar(
          middle: CustomText(
            text: '${widget.title}：詳細入力',
            fontWeight: FontWeight.bold,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 項目名入力フィールド（suffixに履歴ボタンを配置）
                CustomTextField(
                  controller: _nameController,
                  labelText: '項目名',
                  prefixIcon: CupertinoIcons.signature,
                  keyboardType: TextInputType.text,
                  suffix: widget.pastItemNames.isNotEmpty
                      ? CupertinoButton(
                    padding: const EdgeInsets.only(right: 8),
                    onPressed: () => _showSelectPastItemNameDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.clock_fill,
                            size: 13,
                            color: CustomColors.thema,
                          ),
                          SizedBox(width: 4),
                          CustomText(
                            text: '履歴',
                            textSize: TextSize.S,
                            color: CustomColors.thema,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  )
                      : null,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _amountController,
                  labelText: '金額',
                  prefixIcon: CupertinoIcons.money_yen,
                  suffix: AmountToggleButtonView(controller: _amountController),
                ),

                const SizedBox(height: 24),

                CustomElevatedButton(
                  text: widget.amountItem == null ? '追加' : '更新',
                  onPressed: () {
                    _registerAmountItem();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectPastItemNameDialog(BuildContext context) {
    CustomActionPicker.show<String>(
      context: context,
      title: '過去の項目名から選択',
      items: widget.pastItemNames,
      currentValue: null,
      labelBuilder: (name) => name,
      onSelected: (selectedName) {
        setState(() {
          _nameController.text = selectedName;
        });
      },
    );
  }
}