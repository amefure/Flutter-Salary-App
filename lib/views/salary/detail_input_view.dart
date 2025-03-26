import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/models/salary.dart';

/// 金額詳細項目画面
/// Navigator経由でデータを受渡する
class DetailInputView extends StatefulWidget {
  const DetailInputView({super.key, required this.title});

  final String title;

  @override
  State<DetailInputView> createState() => _DetailInputViewState();
}

class _DetailInputViewState extends State<DetailInputView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("項目名と金額を入力してください。"),
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
      padding: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.9,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("${widget.title}：詳細入力"),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [

              SizedBox(height: 60),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "項目名",
                  prefixIcon: Icon(CupertinoIcons.signature),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "金額",
                  prefixIcon: Icon(CupertinoIcons.money_yen),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String name = _nameController.text;
                  int amount = int.tryParse(_amountController.text) ?? 0;

                  if (name.isNotEmpty && amount > 0) {
                    // Navigator経由でデータを返す
                    Navigator.of(context).pop(AmountItem(name, amount));
                  } else {
                    _showErrorDialog(context);
                  }
                },
                child: Text("追加"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
