import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';

class InputSalaryView extends StatefulWidget {
  const InputSalaryView({super.key});

  @override
  State<StatefulWidget> createState() => _InputSalaryViewState();
}

class _InputSalaryViewState extends State<InputSalaryView> {
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _deductionAmountController =
      TextEditingController();
  final TextEditingController _netSalaryController = TextEditingController();

  @override
  void dispose() {
    // メモリ解放
    _paymentAmountController.dispose();
    _deductionAmountController.dispose();
    _netSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Scaffold(
        appBar: AppBar(
          title: Text("登録"),
          actions: [
            IconButton(
              onPressed: () {
                add(context);
              },
              icon: Icon(Icons.check),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _paymentAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "総支給額",
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [Text("総支給額：詳細入力"), Icon(Icons.chevron_right)],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            TextField(
              controller: _deductionAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "控除額",
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
            ),

            Row(
              children: [
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [Text("控除額：詳細入力"), Icon(Icons.chevron_right)],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            TextField(
              controller: _netSalaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "手取り額",
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void add(BuildContext context) {
    int _paymentAmount = int.tryParse(_paymentAmountController.text) ?? 0; 
    int _deductionAmount = int.tryParse(_deductionAmountController.text) ?? 0; 
    int _netSalary = int.tryParse(_netSalaryController.text) ?? 0; 

    final newSalary = Salary(
      Uuid.v4().toString(),
      _paymentAmount,
      _deductionAmount,
      _netSalary,
      DateTime.now(),
      // paymentAmountItems: [
      //   AmountItem('基本給', 400000),
      //   AmountItem('手当', 100000),
      // ],
      // deductionAmountItems: [
      //   AmountItem('税金', 50000),
      //   AmountItem('保険', 50000),
      // ],
      // source: PaymentSource('123', '副業'),
    );

    context.read<SalaryViewModel>().add(newSalary);
    Navigator.of(context).pop();
  }
}
