import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/date_time_utils.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/components/custom_text_field_view.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/input/detail_input_view.dart';
import 'package:salary/views/domain/input/input_payment_source.dart';

/// 給料入力画面
class InputSalaryView extends StatefulWidget {
  const InputSalaryView({super.key, required this.salary});

  final Salary? salary;

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

  /// 支払い元一覧
  List<PaymentSource> _paymentSources = [];
  PaymentSource? selectPaymentSource;

  /// 作成日(給料支給日)
  DateTime _createdAt = DateTime.now();

  /// 総支給詳細アイテム
  List<AmountItem> _paymentAmountItems = [];

  /// 控除額詳細アイテム
  List<AmountItem> _deductionAmountItems = [];

  @override
  void initState() {
    super.initState();

    _paymentSources = context.read<PaymentSourceViewModel>().paymentSources;

    if (widget.salary case Salary salary) {
      DateTime now = salary.createdAt;
      _dateController.text = "${now.year}/${now.month}/${now.day}";
      _paymentAmountController.text = salary.paymentAmount.toString();
      _deductionAmountController.text = salary.deductionAmount.toString();
      _netSalaryController.text = salary.netSalary.toString();
      // mapでコピーを作成しておかないと参照渡しでRealm管理下オブジェクトがわたり
      // write内でないので書き込み権限エラーになる
      // しかしコピーしたものでそのまま更新しようとするとエラーになるので注意
      _paymentAmountItems =
          salary.paymentAmountItems
              .map((item) => AmountItem(item.id, item.key, item.value))
              .toList();

      _deductionAmountItems =
          salary.deductionAmountItems
              .map((item) => AmountItem(item.id, item.key, item.value))
              .toList();
      _paymentSourceController.text = salary.source?.name ?? "未設定";
    } else {
      DateTime now = DateTime.now();
      _dateController.text = "${now.year}/${now.month}/${now.day}";
      _paymentAmountController.text = "0";
      _deductionAmountController.text = "0";
      _netSalaryController.text = "0";
      // 存在するなら一番最初のものを指定
      _paymentSourceController.text =
          _paymentSources.firstOrNull?.name ?? "未設定";
    }
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
          padding: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Doneボタン
              CupertinoButton(
                child: const Text("完了"),
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
          title: const Text("Error"),
          content: const Text("総支給額と手取り額を入力してください。"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// 給料情報新規追加
  void addOrUpdate(BuildContext context) {
    final int? paymentAmount = int.tryParse(_paymentAmountController.text);
    final int? deductionAmount = int.tryParse(_deductionAmountController.text);
    final int? netSalary = int.tryParse(_netSalaryController.text);

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
      source: selectPaymentSource,
    );

    if (widget.salary case Salary salary) {
      context.read<SalaryViewModel>().update(salary, newSalary);
    } else {
      context.read<SalaryViewModel>().add(newSalary);
    }

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return InputPaymentSourceView();
      },
    );
  }

  // 初期選択値
  final String selectedOption = "選択してください";

  /// 選択肢のボタン
  CupertinoActionSheetAction _buildAction(BuildContext context, String option) {
    return CupertinoActionSheetAction(
      onPressed: () {
        _paymentSourceController.text = option;
        try {
          selectPaymentSource = _paymentSources.firstWhere(
            (source) => source.name == option,
          );
        } catch (e) {
          // 一致しない場合はnullを代入
          selectPaymentSource = null;
        }
        Navigator.pop(context);
      },
      child: Text(option),
    );
  }

  /// 支払い元ピッカーを表示
  void _showPaymentSourcePicker(
    BuildContext context,
    List<PaymentSource> paymentSource,
  ) {
    if (paymentSource.isEmpty) {
      // 未登録なら新規登録を促す
      _showInputPaymentSourceModal(context);
    } else {
      // 更新されている可能性があるので上書きしておく
      _paymentSources = paymentSource;
      // 登録済みのリストをピッカーで表示
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: const Text("支払い元を選択してください"),
            actions:
                paymentSource
                    .map((option) => _buildAction(context, option.name))
                    .toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text("キャンセル"),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.foundation,
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle:
              widget.salary == null
                  ? const Text('収入登録画面')
                  : const Text('収入更新画面'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              addOrUpdate(context);
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
                Consumer<PaymentSourceViewModel>(
                  builder: (context, viewModel, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ExpandedでCustomTextFieldのサイズを適切に制約しないとエラーになる
                        Expanded(
                          child: CustomTextField(
                            controller: _paymentSourceController,
                            labelText: "支払い元",
                            prefixIcon: CupertinoIcons.building_2_fill,
                            prefixIconColor:
                                selectPaymentSource?.themaColorEnum.color ??
                                CupertinoColors.systemGrey,
                            readOnly: true,
                            onTap:
                                () => _showPaymentSourcePicker(
                                  context,
                                  viewModel.paymentSources,
                                ),
                          ),
                        ),

                        SizedBox(
                          child: IconButton(
                            onPressed:
                                () => _showInputPaymentSourceModal(context),
                            icon: Icon(
                              CupertinoIcons.add_circled_solid,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 日付ピッカー
                CustomTextField(
                  controller: _dateController,
                  labelText: "日付を選択",
                  prefixIcon: CupertinoIcons.calendar,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _paymentAmountController,
                  labelText: "総支給額",
                  prefixIcon: CupertinoIcons.money_yen,
                ),

                const SizedBox(height: 10),

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
                        return amountItemListRowView(item);
                      }).toList(),
                ),

                const SizedBox(height: 10),
                CustomTextField(
                  controller: _deductionAmountController,
                  labelText: "控除額",
                  prefixIcon: CupertinoIcons.money_yen,
                ),

                Row(
                  children: [
                    const Spacer(),
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
                        return amountItemListRowView(item);
                      }).toList(),
                ),

                const SizedBox(height: 10),
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

  /// AmountItemのリスト行単位のView
  Widget amountItemListRowView(AmountItem item) {
    return Dismissible(
      key: Key(item.id),
      onDismissed: (direction) {
        // 削除処理(どちらかにはあるので削除)
        _paymentAmountItems.remove(item);
        _deductionAmountItems.remove(item);
        _updateTotalPaymentAmount();
        _updateTotalDeductionAmount();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        height: 40,
        child: Row(
          children: [
            const Icon(CupertinoIcons.circle_fill, size: 8),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                text: item.key,
                fontWeight: FontWeight.bold,
                textSize: TextSize.S,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: "${item.value}",
                  fontWeight: FontWeight.bold,
                  textSize: TextSize.M,
                  color: CustomColors.thema,
                ),
                const SizedBox(width: 2),
                CustomText(
                  text: "円",
                  fontWeight: FontWeight.bold,
                  textSize: TextSize.SS,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
