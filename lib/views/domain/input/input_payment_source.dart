import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
import 'package:salary/views/components/custom_text_field_view.dart';

class InputPaymentSourceView extends StatefulWidget {
  const InputPaymentSourceView({super.key});

  @override
  State<InputPaymentSourceView> createState() => _InputPaymentSourceViewState();
}

class _InputPaymentSourceViewState extends State<InputPaymentSourceView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("名称を入力してください。"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: CustomColors.foundation,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(middle: Text("支払い元登録画面")),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: "名称",
                  prefixIcon: CupertinoIcons.signature,
                  keyboardType: TextInputType.text,
                ),

                SizedBox(height: 20),
                CustomElevatedButton(
                  text: "追加",
                  onPressed: () {
                    String name = _nameController.text;
                    if (name.isNotEmpty) {
                      final payment = PaymentSource(Uuid.v4().toString(), name);
                      context.read<PaymentSourceViewModel>().add(payment);
                      Navigator.of(context).pop();
                    } else {
                      _showErrorDialog(context);
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
