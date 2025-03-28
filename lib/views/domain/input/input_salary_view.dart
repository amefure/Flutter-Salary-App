import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/date_time_utils.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/custom_text_field_view.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/input/detail_input_view.dart';
import 'package:salary/views/domain/input/input_payment_source.dart';

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
  final TextEditingController _paymentSourceController =
      TextEditingController();

  /// 作成日(給料支給日)
  DateTime _createdAt = DateTime.now();

  /// 総支給詳細アイテム
  List<AmountItem> _paymentAmountItems = [];

  /// 控除額詳細アイテム
  List<AmountItem> _deductionAmountItems = [];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _dateController.text = "${now.year}/${now.month}/${now.day}";
    _paymentAmountController.text = "0";
    _deductionAmountController.text = "0";
    _netSalaryController.text = "0";
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

  /// **iOS風の日付ホイールピッカーを表示**
  void _selectDate(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Doneボタン
              CupertinoButton(
                child: Text("完了"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              // iOSスタイルの日付ピッカー
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _createdAt,
                  minimumDate: DateTime(DateTime.now().year - 100),
                  maximumDate: DateTime(DateTime.now().year + 100),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _dateController.text = _formatDate(newDate);
                      _createdAt =
                          DateTimeUtils.parse(
                            dateString: _dateController.text,
                            pattern: "yyyy/M/d",
                          ) ??
                          DateTime.now();
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// **DateTime を "YYYY/MM/DD" 形式に変換**
  String _formatDate(DateTime date) {
    return "${date.year}/${date.month}/${date.day}";
  }

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context) {
    showCupertinoDialog(
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

    // どれかが null（不正な入力値）の場合はエラーダイアログを表示
    if (paymentAmount == null || deductionAmount == null || netSalary == null) {
      _showErrorDialog(context);
      return;
    }

    final newSalary = Salary(
      Uuid.v4().toString(),
      paymentAmount,
      deductionAmount,
      netSalary,
      _createdAt,
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

  // 金額詳細アイテム追加画面を表示
  Future<void> _showInputPaymentSourceModal(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return InputPaymentSourceView();
      },
    );
  }

  final List<String> options = ["オプション1", "オプション2", "オプション3"];
  String selectedOption = "選択してください"; // 初期選択値

  /// 選択肢のボタン
  CupertinoActionSheetAction _buildAction(BuildContext context, String option) {
    return CupertinoActionSheetAction(
      onPressed: () {
        _paymentSourceController.text = option;
        setState(() => selectedOption = option);
        Navigator.pop(context);
      },
      child: Text(option),
    );
  }

  /// ピッカーを表示
  void _showPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text("選択してください"),
          actions:
              options.map((option) => _buildAction(context, option)).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("キャンセル"),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.foundation,
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('収入登録画面'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              add(context);
            },
            child: const Icon(
              CupertinoIcons.check_mark_circled_solid,
              size: 28,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expanded を追加して CustomTextField のサイズを適切に制約しないとエラーになる
                    Expanded(
                      child: CustomTextField(
                        controller: _paymentSourceController,
                        labelText: "支払い元",
                        prefixIcon: CupertinoIcons.building_2_fill,
                        readOnly: true,
                        onTap: () => _showPicker(context),
                      ),
                    ),

                    SizedBox(
                      child: IconButton(
                        onPressed: () => _showInputPaymentSourceModal(context),
                        icon: Icon(CupertinoIcons.add_circled_solid, size: 28),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // 日付ピッカー
                CustomTextField(
                  controller: _dateController,
                  labelText: "日付を選択",
                  prefixIcon: CupertinoIcons.calendar,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),

                SizedBox(height: 20),

                CustomTextField(
                  controller: _paymentAmountController,
                  labelText: "総支給額",
                  prefixIcon: CupertinoIcons.money_yen,
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
                        children: [
                          CustomText(
                            text: "総支給額：詳細入力",
                            color: CustomColors.thema,
                            textSize: TextSize.S,
                            fontWeight: FontWeight.bold,
                          ),
                          Icon(Icons.chevron_right),
                        ],
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
                CustomTextField(
                  controller: _deductionAmountController,
                  labelText: "控除額",
                  prefixIcon: CupertinoIcons.money_yen,
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
                        children: [
                          CustomText(
                            text: "控除額：詳細入力",
                            color: CustomColors.thema,
                            textSize: TextSize.S,
                            fontWeight: FontWeight.bold,
                          ),
                          Icon(Icons.chevron_right),
                        ],
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
                CustomTextField(
                  controller: _netSalaryController,
                  labelText: "手取り額",
                  prefixIcon: CupertinoIcons.money_yen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
