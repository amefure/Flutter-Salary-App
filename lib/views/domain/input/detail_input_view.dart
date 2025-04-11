import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
import 'package:salary/views/components/custom_text_field_view.dart';
import 'package:salary/views/components/custom_text_view.dart';

/// 金額詳細項目画面
/// Navigator経由でデータを受渡する
class DetailInputView extends StatefulWidget {
  const DetailInputView({super.key, required this.title, this.amountItem});

  final String title;
  final AmountItem? amountItem;

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
            text: "ERROR",
            fontWeight: FontWeight.bold,
          ),
          content: CustomText(
            text: title,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const CustomText(
                text: "OK",
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: CustomColors.foundation,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle: CustomText(
            text: "${widget.title}：詳細入力",
            fontWeight: FontWeight.bold,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: "項目名",
                  prefixIcon: CupertinoIcons.signature,
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 10),

                CustomTextField(
                  controller: _amountController,
                  labelText: "金額",
                  prefixIcon: CupertinoIcons.money_yen,
                ),

                const SizedBox(height: 20),
                CustomElevatedButton(
                  text: "追加",
                  onPressed: () {
                    String name = _nameController.text;
                    int amount = int.tryParse(_amountController.text) ?? 0;

                    if (_amountController.text.length > 19) {
                      _showErrorDialog(context, "19桁以上は入力できません。");
                      return;
                    }

                    if (name.isEmpty || amount < 0) {
                      _showErrorDialog(context, "項目名と金額を入力してください。");
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
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
