import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/domain/input_salary/input_salary_state.dart';
import 'package:salary/domain/input_salary/input_salary_view_model.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/utilities/date_time_utils.dart';
import 'package:salary/utilities/number_utils.dart';
import 'package:salary/common/components/ad_banner_widget.dart';
import 'package:salary/common/components/custom_label_view.dart';
import 'package:salary/common/components/custom_text_field_view.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/domain/detail_input_view.dart';
import 'package:salary/domain/input_payment_source/input_payment_source_view.dart';

/// 給料入力画面
class InputSalaryView extends ConsumerWidget {
  const InputSalaryView({super.key, required this.salary});
  final Salary? salary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(inputSalaryProvider(salary).notifier);
    return Scaffold(
      backgroundColor: CustomColors.foundation(context),
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation(context),
        navigationBar: CupertinoNavigationBar(
          middle:
          salary == null ? const Text('給料登録画面') : const Text('給料更新画面'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              try {
                vm.addOrUpdate();
                Navigator.of(context).pop();
              } on InputSalaryException catch (e) {
                _showErrorDialog(context, e.message);
              }
            },
            child: const Icon(
              CupertinoIcons.check_mark_circled_solid,
              size: 28,
            ),
          )
        ),
        child: _BodyWidget(salary: salary),
      ),
    );
  }

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context, String title) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(title),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _BodyWidget extends ConsumerStatefulWidget {
  final Salary? salary;
  const _BodyWidget({required this.salary});

  @override
  ConsumerState<_BodyWidget> createState() => _Body();
}


class _Body extends ConsumerState<_BodyWidget> {
  final TextEditingController _paymentAmountController = TextEditingController();
  final TextEditingController _deductionAmountController = TextEditingController();
  final TextEditingController _netSalaryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _paymentSourceController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  late final ProviderSubscription<InputSalaryState> _subscription;

  @override
  void initState() {
    super.initState();
    // TextEditingController =>(変化) ViewModel.Stateと同期
    _bindControllersToState();
    // ViewModel.State =>(変化) TextEditingControllerと同期
    _bindStateToControllers();
  }

  /// ViewModel.State =>(変化) TextEditingControllerと同期
  void _bindStateToControllers() {
    _subscription = ref.listenManual<InputSalaryState>(
      inputSalaryProvider(widget.salary),
      fireImmediately: true,
          (prev, next) {
            _syncController(_paymentSourceController, next.getPaymentSourceName());
            _syncController(_paymentAmountController, next.paymentAmount);
            _syncController(_deductionAmountController, next.deductionAmount);
            _syncController(_netSalaryController, next.netSalary);
            _syncController(_memoController, next.memo);
            _syncController(_dateController, next.getDisplayDate());
      },
    );
  }

  void _syncController(
      TextEditingController controller,
      String newValue,
      ) {
    if (controller.text == newValue) return;

    // build外 & フレーム後に安全に更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.text = newValue;
    });
  }


  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(inputSalaryProvider(widget.salary).notifier);

    // 入力されたらViewModelに反映
    _paymentAmountController.addListener(() {
      vm.updatePaymentAmount(_paymentAmountController.text);
    });
    _deductionAmountController.addListener(() {
      vm.updateDeductionAmount(_deductionAmountController.text);
    });
    _netSalaryController.addListener(() {
      vm.updateNetSalary(_netSalaryController.text);
    });
    _memoController.addListener(() {
      vm.updateMemo(_memoController.text);
    });
  }

  @override
  void dispose() {
    // メモリ解放
    _subscription.close();
    _paymentAmountController.dispose();
    _deductionAmountController.dispose();
    _netSalaryController.dispose();
    _dateController.dispose();
    _paymentSourceController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inputSalaryProvider(widget.salary));
    final vm = ref.read(inputSalaryProvider(widget.salary).notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 給料履歴一覧
            if (state.historyList.isNotEmpty)
              _historyCitingSalaryButton(state.historyList, vm.copySalaryFromPast),

            // 支払い元ピッカー
            _paymentSourcePicker(
                prefixIconColor: state.selectPaymentSource?.themaColorEnum
                    .color ?? CupertinoColors.systemGrey,
                onTapped: () {
                  // 支払い元表示前に再取得 & Stateリフレッシュ
                  final paymentSources = vm.fetchAndRefreshPaymentSources();
                  // ピッカー表示
                  _showPaymentSourcePicker(
                      context,
                      // Stateリフレッシュは反映されないので取得してそのまま渡す
                      paymentSources,
                      vm.updateSelectPaymentSource
                  );
                }
            ),

            const SizedBox(height: 20),

            // 日付ピッカー
            CustomTextField(
              controller: _dateController,
              labelText: '支給日',
              prefixIcon: CupertinoIcons.calendar,
              readOnly: true,
              onTap: () =>
                  _showSelectDatePicker(
                      context,
                      state.createdAt,
                      vm.selectDate
                  ),
            ),

            const SizedBox(height: 20),

            // 総支給額UI
            CustomTextField(
              controller: _paymentAmountController,
              labelText: '総支給額',
              prefixIcon: CupertinoIcons.money_yen,
              onSubmitted: (_) => vm.calcNetSalaryAmount(),
              onFocusLost: () => vm.calcNetSalaryAmount(),
            ),

            const SizedBox(height: 10),

            // 総支給額：詳細入力
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    // 詳細画面入力モーダルを表示
                    _showInputAmountItemModal(
                        context, '総支給額', vm.addPaymentAmountItem);
                  },
                  child: const Row(
                    children: [
                      CustomText(
                        text: '総支給額：詳細入力',
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
              state.paymentAmountItems.map((item) {
                return _amountItemListRowView(
                    item: item,
                    title: '総支給額',
                    onDismissed: vm.removePaymentAmountItem,
                    update: vm.updatePaymentAmountItem
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // 控除額
            CustomTextField(
              controller: _deductionAmountController,
              labelText: '控除額',
              prefixIcon: CupertinoIcons.money_yen,
              onSubmitted: (_) => vm.calcNetSalaryAmount(),
              onFocusLost: () => vm.calcNetSalaryAmount(),
            ),

            // 控除額：詳細入力
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    // 詳細画面入力モーダルを表示
                    _showInputAmountItemModal(
                        context, '控除額', vm.addDeductionAmountItem);
                  },
                  child: const Row(
                    children: [
                      CustomText(
                        text: '控除額：詳細入力',
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
              state.deductionAmountItems.map((item) {
                return _amountItemListRowView(
                    item: item,
                    title: '控除額',
                    onDismissed: vm.removeDeductionAmountItem,
                    update: vm.updateDeductionAmountItem
                );
              }).toList(),
            ),

            const SizedBox(height: 10),
            CustomTextField(
              controller: _netSalaryController,
              labelText: '手取り額',
              prefixIcon: CupertinoIcons.money_yen,
            ),

            const SizedBox(height: 20),

            const CustomLabelView(labelText: '賞与'),

            const SizedBox(height: 8),

            Row(
              children: [

                const Spacer(),

                CupertinoSwitch(
                  activeTrackColor: CustomColors.thema,
                  value: state.isBonus,
                  onChanged: (bool value) {
                    vm.updateIsBonus(value);
                  },
                ),
              ],
            ),

            CustomTextField(
              controller: _memoController,
              labelText: 'MEMO',
              prefixIcon: Icons.comment,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),

            const SizedBox(height: 40),

            const AdMobBannerWidget(),
          ],
        ),
      ),
    );
  }


  /// 支払い元ピッカー
  Widget _paymentSourcePicker({
    required Color prefixIconColor,
    required VoidCallback onTapped
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ExpandedでCustomTextFieldのサイズを適切に制約しないとエラーになる
        Expanded(
          child: CustomTextField(
            controller: _paymentSourceController,
            labelText: '支払い元',
            prefixIcon: CupertinoIcons.building_2_fill,
            prefixIconColor: prefixIconColor,
            readOnly: true,
            onTap: onTapped,
          ),
        ),

        SizedBox(
          child: IconButton(
            onPressed: () => _showInputPaymentSourceModal(context),
            icon: const Icon(CupertinoIcons.add_circled_solid, size: 28),
          ),
        ),
      ],
    );
  }

  /// AmountItemのリスト行単位のView
  Widget _amountItemListRowView({
    required AmountItem item,
    required String title,
    required Function(AmountItem item) onDismissed,
    required Function({ required AmountItem oldItem, required AmountItem newItem }) update,
  }) {
    return Dismissible(
      key: Key(item.id),
      onDismissed: (direction) {
        onDismissed(item);
      },
      child: GestureDetector(
        onTap: () async {
          // 結果をawaitで同期的に取得する
          final AmountItem? newItem = await showModalBottomSheet<AmountItem?>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return DetailInputView(title: title, amountItem: item);
            },
          );

          if (newItem != null) {
            update(oldItem: item, newItem: newItem);
          }
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
                    text: NumberUtils.formatWithComma(item.value),
                    fontWeight: FontWeight.bold,
                    textSize: TextSize.M,
                    color: CustomColors.thema,
                  ),
                  const SizedBox(width: 2),
                  const CustomText(
                    text: '円',
                    fontWeight: FontWeight.bold,
                    textSize: TextSize.SS,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// iOS風の日付ホイールピッカーを表示
  void _showSelectDatePicker(
      BuildContext context,
      DateTime initialDateTime,
      Function(DateTime newDate) onDateTimeChanged
      ) {
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
                child: const Text('完了'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              // iOSスタイルの日付ピッカー
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDateTime,
                  minimumDate: DateTime(DateTime.now().year - 100),
                  maximumDate: DateTime(DateTime.now().year + 100),
                  onDateTimeChanged: onDateTimeChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  /// 金額詳細アイテム追加画面を表示
  Future<void> _showInputAmountItemModal(
      BuildContext context,
      String title,
      void Function(AmountItem source) onAdded,
      ) async {
    // 結果をawaitで同期的に取得する
    final AmountItem? newItem = await showModalBottomSheet<AmountItem?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DetailInputView(title: title);
      },
    );
    if (newItem != null) {
      onAdded(newItem);
    }
  }

  /// 支払い元ピッカーを表示
  void _showPaymentSourcePicker(
      BuildContext context,
      List<PaymentSource> paymentSource,
      void Function(PaymentSource source) onPressed
      ) {
    if (paymentSource.isEmpty) {
      // 未登録なら新規登録を促す
      _showInputPaymentSourceModal(context);
    } else {
      // 登録済みのリストをピッカーで表示
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: const Text('支払い元を選択してください'),
            actions:
            paymentSource
                .map((source) => _pickerItemButton(context, source, onPressed))
                .toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
          );
        },
      );
    }
  }

  /// 過去の給料情報表示ボタン
  Widget _historyCitingSalaryButton(
      List<Salary> pastSalaries,
      void Function(Salary salary) onSelected
      ) {
    return Row(
      children: [
        const Spacer(),
        CupertinoButton(
          child: const Row(
            children: [
              CustomText(
                text: '過去から引用',
                color: CustomColors.thema,
                textSize: TextSize.S,
                fontWeight: FontWeight.bold,
              ),
              Icon(Icons.chevron_right),
            ],
          ),
          onPressed: () {
            _showSelectPastSalarySheet(pastSalaries, onSelected);
          },
        ),
      ],
    );
  }

  /// 過去の給料情報選択アクションシートを表示
  void _showSelectPastSalarySheet(
      List<Salary> pastSalaries,
      void Function(Salary salary) onSelected
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoActionSheet(
          title: const Text('引用する過去の情報を選択'),
          actions:
          pastSalaries.map((salary) {
            final dateStr = DateTimeUtils.format(
              dateTime: salary.createdAt,
            );
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(dialogContext);
                onSelected(salary);
              },
              child: CustomText(
                text: '$dateStr${salary.isBonus ? '(賞)': ''} - ${salary.source?.name ?? "未設定"} ',
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
        );
      },
    );
  }


  /// 支払い元追加画面を表示
  Future<void> _showInputPaymentSourceModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const InputPaymentSourceView();
      },
    );
  }


  /// 支払い元選択肢のボタン
  CupertinoActionSheetAction _pickerItemButton(
      BuildContext context, PaymentSource source,
      void Function(PaymentSource source) onPressed
      ) {
    return CupertinoActionSheetAction(
      onPressed: () {
        onPressed(source);
        Navigator.pop(context);
      },
      child: CustomText(text: source.name),
    );
  }

}