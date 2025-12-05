import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/repository/shared_prefs_repository.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/utilitys/date_time_utils.dart';
import 'package:salary/utilitys/number_utils.dart';
import 'package:salary/viewmodels/reverpod/payment_source_notifier.dart';
import 'package:salary/viewmodels/reverpod/salary_notifier.dart';
import 'package:salary/views/components/ad_banner_widget.dart';
import 'package:salary/views/components/custom_text_field_view.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/domain/input/detail_input_view.dart';
import 'package:salary/views/domain/input/input_payment_source.dart';

/// 給料入力画面
class InputSalaryView extends ConsumerStatefulWidget {
  const InputSalaryView({super.key, required this.salary});

  final Salary? salary;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InputSalaryViewState();
}

class _InputSalaryViewState extends ConsumerState<InputSalaryView> {
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _deductionAmountController =
      TextEditingController();
  final TextEditingController _netSalaryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _paymentSourceController =
      TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  /// 支払い元一覧
  List<PaymentSource> _paymentSources = [];
  PaymentSource? _selectPaymentSource;

  /// 作成日(給料支給日)
  DateTime _createdAt = DateTime.now();

  /// 総支給詳細アイテム
  List<AmountItem> _paymentAmountItems = [];

  /// 控除額詳細アイテム
  List<AmountItem> _deductionAmountItems = [];

  List<Salary> _historyList = [];

  /// 広告削除
  bool _removeAds = false;

  @override
  void initState() {
    super.initState();
    _fetchRemoveAds();
    // 現在のSalary履歴を取得
    // 編集対象は除去
    _historyList = ref.read(salaryProvider).where((salary) => salary.id != widget.salary?.id).toList();


    _paymentSources = ref.read(paymentSourceProvider);

    if (widget.salary case Salary salary) {
      DateTime now = salary.createdAt;
      _dateController.text = '${now.year}/${now.month}/${now.day}';
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
      _paymentSourceController.text = salary.source?.name ?? '未設定';
      _selectPaymentSource = salary.source;
      _createdAt = salary.createdAt;
      _memoController.text = salary.memo;
    } else {
      DateTime now = DateTime.now();
      _dateController.text = '${now.year}/${now.month}/${now.day}';
      _paymentAmountController.text = '';
      _deductionAmountController.text = '';
      _netSalaryController.text = '';
      // 存在するなら一番最初のものを指定
      _selectPaymentSource = _paymentSources.firstOrNull;
      _paymentSourceController.text = _selectPaymentSource?.name ?? '未設定';
    }
  }

  /// 広告削除フラグを取得
  Future<void> _fetchRemoveAds() async {
    bool removeAds = SharedPreferencesService().fetchRemoveAds();
    setState(() {
      _removeAds = removeAds;
    });
  }

  @override
  void dispose() {
    // メモリ解放
    _paymentAmountController.dispose();
    _deductionAmountController.dispose();
    _netSalaryController.dispose();
    _dateController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// **総支給額の合計金額を計算しUI反映**
  void _updateTotalPaymentAmount() {
    int total = _paymentAmountItems.fold(0, (sum, item) => sum + item.value);
    _paymentAmountController.text = total.toString();
    _calcNetSalaryAmount();
  }

  /// **控除額の合計金額を計算しUI反映**
  void _updateTotalDeductionAmount() {
    int total = _deductionAmountItems.fold(0, (sum, item) => sum + item.value);
    _deductionAmountController.text = total.toString();
    _calcNetSalaryAmount();
  }

  /// **手取りの合計金額を計算しUI反映**
  void _calcNetSalaryAmount() {
    final int? paymentAmount = int.tryParse(_paymentAmountController.text);
    final int? deductionAmount = int.tryParse(_deductionAmountController.text);

    // どれかが null（不正な入力値）の場合はエラーダイアログを表示
    if (paymentAmount == null || deductionAmount == null) {
      return;
    }

    final int netSalary = paymentAmount - deductionAmount;
    _netSalaryController.text = netSalary.toString();
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
                child: const Text('完了'),
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
                      final selectYearAndMonth =
                          DateTimeUtils.parse(
                            dateString: _dateController.text,
                            pattern: 'yyyy/M/d',
                          ) ??
                          DateTime.now();
                      // selectYearAndMonthは時間は0:00になっている
                      // JTCの9時間の差分保存後にずれてしまうので
                      // 先に12時間ほどずらしておく
                      _createdAt = selectYearAndMonth.add(
                        const Duration(hours: 12),
                      );
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
    return '${date.year}/${date.month}/${date.day}';
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

  /// **桁数バリデーション**
  void _validationLength() {
    // 桁数バリデーション
    // int は 64ビット整数 であり、以下の範囲の値を保持できます。
    // 最小値: -9,223,372,036,854,775,808 (-2^63)
    // 最大値: 9,223,372,036,854,775,807 (2^63 - 1)
    if (_paymentAmountController.text.length > 19 ||
        _deductionAmountController.text.length > 19 ||
        _netSalaryController.text.length > 19) {
      _showErrorDialog(context, '19桁以上は入力できません。');
      return;
    }
  }

  /// 給料情報新規追加
  void _addOrUpdate(BuildContext context, WidgetRef ref) {
    // 桁数バリデーション
    _validationLength();

    final int? paymentAmount = int.tryParse(_paymentAmountController.text);
    final int? deductionAmount = int.tryParse(_deductionAmountController.text);
    final int? netSalary = int.tryParse(_netSalaryController.text);
    final String memo = _memoController.text;

    // どれかが null（不正な入力値）の場合はエラーダイアログを表示
    if (paymentAmount == null || deductionAmount == null || netSalary == null) {
      _showErrorDialog(context, '総支給額、控除額、手取り額を入力してください。');
      return;
    }

    final newSalary = Salary(
      Uuid.v4().toString(),
      paymentAmount,
      deductionAmount,
      netSalary,
      _createdAt,
      memo,
      paymentAmountItems: _paymentAmountItems,
      deductionAmountItems: _deductionAmountItems,
      source: _selectPaymentSource,
    );

    if (widget.salary case Salary salary) {
      ref.read(salaryProvider.notifier).update(salary, newSalary);
    } else {
      ref.read(salaryProvider.notifier).add(newSalary);
    }

    Navigator.of(context).pop();
  }

  /// 金額詳細アイテム追加画面を表示
  Future<void> _showInputAmountItemModal(
    BuildContext context,
    bool isPayment,
  ) async {
    String title = '';
    if (isPayment) {
      title = '総支給額';
    } else {
      title = '控除額';
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

  /// 金額詳細アイテム追加画面を表示
  Future<void> _showInputPaymentSourceModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const InputPaymentSourceView();
      },
    );
  }

  /// 選択肢のボタン
  CupertinoActionSheetAction _buildAction(BuildContext context, String option) {
    return CupertinoActionSheetAction(
      onPressed: () {
        _paymentSourceController.text = option;
        try {
          _selectPaymentSource = _paymentSources.firstWhere(
            (source) => source.name == option,
          );
        } catch (e) {
          // 一致しない場合はnullを代入
          _selectPaymentSource = null;
        }
        Navigator.pop(context);
      },
      child: CustomText(text: option),
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
            title: const Text('支払い元を選択してください'),
            actions:
                paymentSource
                    .map((option) => _buildAction(context, option.name))
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
          trailing: Consumer(
            builder: (_, ref, _) {
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _addOrUpdate(context, ref);
                },
                child: const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  size: 28,
                ),
              );
            },
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_historyList.isNotEmpty) _historyCitingSalary(_historyList),

                // 支払い元ピッカー
                _paymentSourcePicker(),

                const SizedBox(height: 20),

                // 日付ピッカー
                CustomTextField(
                  controller: _dateController,
                  labelText: '支給日',
                  prefixIcon: CupertinoIcons.calendar,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 20),

                // 総支給額UI
                CustomTextField(
                  controller: _paymentAmountController,
                  labelText: '総支給額',
                  prefixIcon: CupertinoIcons.money_yen,
                  onSubmitted: (_) => _calcNetSalaryAmount(),
                  onFocusLost: () => _calcNetSalaryAmount(),
                ),

                const SizedBox(height: 10),

                // 総支給額：詳細入力
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        // 詳細画面入力モーダルを表示
                        _showInputAmountItemModal(context, true);
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
                      _paymentAmountItems.map((item) {
                        return _amountItemListRowView(item, true);
                      }).toList(),
                ),

                const SizedBox(height: 10),

                // 控除額
                CustomTextField(
                  controller: _deductionAmountController,
                  labelText: '控除額',
                  prefixIcon: CupertinoIcons.money_yen,
                  onSubmitted: (_) => _calcNetSalaryAmount(),
                  onFocusLost: () => _calcNetSalaryAmount(),
                ),

                // 控除額：詳細入力
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        // 詳細画面入力モーダルを表示
                        _showInputAmountItemModal(context, false);
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
                      _deductionAmountItems.map((item) {
                        return _amountItemListRowView(item, false);
                      }).toList(),
                ),

                const SizedBox(height: 10),
                CustomTextField(
                  controller: _netSalaryController,
                  labelText: '手取り額',
                  prefixIcon: CupertinoIcons.money_yen,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _memoController,
                  labelText: 'MEMO',
                  prefixIcon: Icons.comment,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),

                const SizedBox(height: 40),

                if (!_removeAds)
                  const AdMobBannerWidget(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _historyCitingSalary(List<Salary> pastSalaries) {
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
            _showSelectPastSalarySheet(pastSalaries);
          },
        ),
      ],
    );
  }

  void _showSelectPastSalarySheet(List<Salary> pastSalaries) {
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
                    _copySalaryFromPast(salary);
                  },
                  child: CustomText(
                    text: '$dateStr - ${salary.source?.name ?? "未設定"} ',
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

  void _copySalaryFromPast(Salary pastSalary) {
    setState(() {
      _selectPaymentSource = pastSalary.source;
      if (_selectPaymentSource != null) {
        _paymentSourceController.text = _selectPaymentSource!.name.toString();
      }
      _paymentAmountItems =
          pastSalary.paymentAmountItems
              .map(
                (item) =>
                    AmountItem(Uuid.v4().toString(), item.key, item.value),
              )
              .toList();
      if (_paymentAmountItems.isEmpty) {
        _paymentAmountController.text = pastSalary.paymentAmount.toString();
      } else {
        _updateTotalPaymentAmount();
      }
      _deductionAmountItems =
          pastSalary.deductionAmountItems
              .map(
                (item) =>
                    AmountItem(Uuid.v4().toString(), item.key, item.value),
              )
              .toList();
      if (_deductionAmountItems.isEmpty) {
        _deductionAmountController.text = pastSalary.deductionAmount.toString();
      } else {
        _updateTotalDeductionAmount();
      }

      _memoController.text = pastSalary.memo;

      _calcNetSalaryAmount();
    });
  }

  /// 支払い元ピッカー
  Widget _paymentSourcePicker() {
    return Consumer(
      builder: (context, ref, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ExpandedでCustomTextFieldのサイズを適切に制約しないとエラーになる
            Expanded(
              child: CustomTextField(
                controller: _paymentSourceController,
                labelText: '支払い元',
                prefixIcon: CupertinoIcons.building_2_fill,
                prefixIconColor:
                    _selectPaymentSource?.themaColorEnum.color ??
                    CupertinoColors.systemGrey,
                readOnly: true,
                onTap:
                    () => _showPaymentSourcePicker(
                      context,
                      ref.read(paymentSourceProvider),
                    ),
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
      },
    );
  }

  /// AmountItemのリスト行単位のView
  Widget _amountItemListRowView(AmountItem item, bool isPayment) {
    return Dismissible(
      key: Key(item.id),
      onDismissed: (direction) {
        // 削除処理
        _paymentAmountItems.remove(item);
        _deductionAmountItems.remove(item);
        _updateTotalPaymentAmount();
        _updateTotalDeductionAmount();
      },
      child: GestureDetector(
        onTap: () async {
          String title = '';
          if (isPayment) {
            title = '総支給額';
          } else {
            title = '控除額';
          }
          _paymentAmountItems.remove(item);
          _deductionAmountItems.remove(item);
          // 結果をawaitで同期的に取得する
          final AmountItem? newItem = await showModalBottomSheet<AmountItem?>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return DetailInputView(title: title, amountItem: item);
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
}
