import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/date_time_utils.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/salary/detail_input_view.dart';

/// 給料入力画面
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
  final TextEditingController _dateController = TextEditingController();

  /// 総支給詳細アイテム
  List<AmountItem> _paymentAmountItems = [];

  /// 控除額詳細アイテム
  List<AmountItem> _deductionAmountItems = [];


  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _dateController.text = "${now.year}/${now.month}/${now.day}";
  }

  @override
  void dispose() {
    // メモリ解放
    _paymentAmountController.dispose();
    _deductionAmountController.dispose();
    _netSalaryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// **総支給額の合計金額を計算しUI反映**
  void _updateTotalPaymentAmount() {
    int total = _paymentAmountItems.fold(0, (sum, item) => sum + item.value);
    _paymentAmountController.text = total.toString();
  }

  /// **控除額の合計金額を計算しUI反映**
  void _updateTotalDeductionAmount() {
    int total = _deductionAmountItems.fold(0, (sum, item) => sum + item.value);
    _deductionAmountController.text = total.toString();
  }

  /// **控除額の合計金額を計算しUI反映**
  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = "${picked.year}/${picked.month}/${picked.day}";
    }
  }

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("総支給額と手取り額を入力してください。"),
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

  /// 給料情報新規追加
  void add(BuildContext context) {
    int? paymentAmount = int.tryParse(_paymentAmountController.text);
    int? deductionAmount = int.tryParse(_deductionAmountController.text);
    int? netSalary = int.tryParse(_netSalaryController.text);
    DateTime? createdAt = DateTimeUtils.parse(
      dateString: _dateController.text,
      pattern: "yyyy/M/d",
    );

    // どれかが null（不正な入力値）の場合はエラーダイアログを表示
    if (paymentAmount == null ||
        deductionAmount == null ||
        netSalary == null ||
        createdAt == null) {
      _showErrorDialog(context);
      return;
    }

    final newSalary = Salary(
      Uuid.v4().toString(),
      paymentAmount,
      deductionAmount,
      netSalary,
      createdAt,
      paymentAmountItems: _paymentAmountItems,
      deductionAmountItems: _deductionAmountItems,
      // source: PaymentSource('123', '副業'),
    );

    context.read<SalaryViewModel>().add(newSalary);
    Navigator.of(context).pop();
  }

  /// 金額詳細アイテム追加画面を表示
  Future<void> _showInputAmountItemModal(
    BuildContext context,
    bool isPayment,
  ) async {
    String title = "";
    if (isPayment) {
      title = "総支給額";
    } else {
      title = "控除額";
    }
    // 結果をawaitで同期的に取得する
    final AmountItem? newItem = await showModalBottomSheet<AmountItem?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DetailInputView(title: title);
      },
    );

    if (newItem != null) {
      setState(() {
        if (isPayment) {
          // 総支給額に追加
          _paymentAmountItems.add(newItem);
          // UIを更新
          _updateTotalPaymentAmount();
        } else {
          // 控除額に追加
          _deductionAmountItems.add(newItem);
          // UIを更新
          _updateTotalDeductionAmount();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('給料MEMO'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add, size: 28),
            onPressed: () {
              add(context);
            },
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 120),

              // TextField の実装
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "日付を選択",
                  suffixIcon: Icon(CupertinoIcons.calendar),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),

              SizedBox(height: 20),

              TextField(
                controller: _paymentAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "総支給額",
                  prefixIcon: Icon(CupertinoIcons.money_yen),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              Row(
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      // 詳細画面入力モーダルを表示
                      _showInputAmountItemModal(context, true);
                    },
                    child: Row(
                      children: [Text("総支給額：詳細入力"), Icon(Icons.chevron_right)],
                    ),
                  ),
                ],
              ),

              // 追加された AmountItem を表示
              Column(
                children:
                    _paymentAmountItems.map((item) {
                      return ListTile(
                        title: Text(item.key),
                        trailing: Text("${item.value}円"),
                      );
                    }).toList(),
              ),

              SizedBox(height: 10),
              TextField(
                controller: _deductionAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "控除額",
                  prefixIcon: Icon(CupertinoIcons.money_yen),
                  border: OutlineInputBorder(),
                ),
              ),

              Row(
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      // 詳細画面入力モーダルを表示
                      _showInputAmountItemModal(context, false);
                    },
                    child: Row(
                      children: [Text("控除額：詳細入力"), Icon(Icons.chevron_right)],
                    ),
                  ),
                ],
              ),

              // 追加された AmountItem を表示
              Column(
                children:
                    _deductionAmountItems.map((item) {
                      return ListTile(
                        title: Text(item.key),
                        trailing: Text("${item.value}円"),
                      );
                    }).toList(),
              ),

              SizedBox(height: 10),
              TextField(
                controller: _netSalaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "手取り額",
                  prefixIcon: Icon(CupertinoIcons.money_yen),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
