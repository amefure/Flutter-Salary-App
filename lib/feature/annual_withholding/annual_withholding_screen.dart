import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/empty_state_view.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_withholding/annual_withholding_view_model.dart';
import 'package:salary/feature/annual_withholding/components/annual_withholding_editor_modal.dart';
import 'package:salary/feature/annual_withholding/domain/annual_withholding_labels.dart';
import 'package:salary/feature/payment_source/input/input_payment_source_view.dart';

class AnnualWithholdingScreen extends ConsumerStatefulWidget {
  const AnnualWithholdingScreen({super.key});

  @override
  ConsumerState<AnnualWithholdingScreen> createState() =>
      _AnnualWithholdingScreenState();
}

class _AnnualWithholdingScreenState
    extends ConsumerState<AnnualWithholdingScreen> {
  final _numberFormatter = NumberFormat('#,###');
  late int _selectedYear;
  late final TextEditingController _yearController;

  // 各カードの開閉状態をIDで管理するマップ
  final Map<String, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _yearController = TextEditingController(
      text: '$_selectedYear${AnnualWithholdingLabels.yearSuffix}',
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  List<AnnualWithholding> get _itemsForSelectedYear {
    final state = ref.watch(annualWithholdingProvider);
    final items =
    state.items.where((item) => item.year == _selectedYear).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<PaymentSource> get _paymentSources {
    return ref.watch(annualWithholdingProvider).paymentSources;
  }

  int get _totalPaymentAmount {
    return _itemsForSelectedYear.fold<int>(
      0,
          (sum, item) => sum + item.paymentAmount,
    );
  }

  int get _totalTaxAmount {
    return _itemsForSelectedYear.fold<int>(
      0,
          (sum, item) => sum + item.incomeTaxAmount,
    );
  }

  String _paymentSourceName(String? paymentSourceId) {
    if (paymentSourceId == null || paymentSourceId.isEmpty) {
      return AnnualWithholdingLabels.unknownPaymentSource;
    }
    for (final source in _paymentSources) {
      if (source.id == paymentSourceId) {
        return source.name;
      }
    }
    return AnnualWithholdingLabels.unknownPaymentSource;
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
      _yearController.text = '$year${AnnualWithholdingLabels.yearSuffix}';
    });
  }

  Future<void> _showYearPicker() async {
    final years = List<int>.generate(131, (index) => 1970 + index);
    var pickerIndex = years.indexOf(_selectedYear);
    if (pickerIndex < 0) pickerIndex = years.length ~/ 2;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        var selectedIndex = pickerIndex;
        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: CustomColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: null,
                      child: CustomText(text: '年を選択', fontWeight: FontWeight.bold),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const CustomText(
                        text: AnnualWithholdingLabels.pickerDone,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.thema,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _selectYear(years[selectedIndex]);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setPickerState) {
                    return CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: pickerIndex,
                      ),
                      itemExtent: 44,
                      onSelectedItemChanged: (index) {
                        setPickerState(() => selectedIndex = index);
                      },
                      children: [
                        for (final year in years)
                          Center(
                            child: CustomText(
                              text: '$year${AnnualWithholdingLabels.yearSuffix}',
                              textSize: TextSize.MS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditor({AnnualWithholding? existing}) async {
    final sources = _paymentSources;
    if (sources.isEmpty) {
      final result = await AppDialog.show(
        context: context,
        message: AnnualWithholdingLabels.addNewPaymentSourceConfirm,
        type: DialogType.confirm,
        positiveTitle: '登録する',
        isPositiveNegativeType: false,
      );
      if (result ?? false) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const InputPaymentSourceView(),
        );
        ref.read(annualWithholdingProvider.notifier).fetchAll();
      }
      return;
    }

    await Navigator.of(context).push<void>(
      CupertinoPageRoute(
        builder: (context) => AnnualWithholdingEditorModal(
          existing: existing,
          selectedYear: _selectedYear,
          paymentSources: sources,
          onSaved: (item) {
            final isSaved = ref
                .read(annualWithholdingProvider.notifier)
                .save(item: item);
            if (!isSaved) {
              AppDialog.show(
                context: context,
                message: AnnualWithholdingLabels.duplicateWarning,
                type: DialogType.error,
              );
              return false;
            }
            return true;
          },
        ),
      ),
    );
  }

  void _confirmDelete(String id) async {
    final result = await AppDialog.show(
      context: context,
      message: AnnualWithholdingLabels.deleteConfirm,
      type: DialogType.confirm,
      positiveTitle: '削除',
      isPositiveNegativeType: true,
    );
    if (result ?? false) {
      ref.read(annualWithholdingProvider.notifier).deleteById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsForSelectedYear;

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: AnnualWithholdingLabels.screenTitle,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomColors.thema.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_text_fill,
                        size: 18,
                        color: CustomColors.thema,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CustomText(
                      text: '$_selectedYear年の源泉徴収管理',
                      textSize: TextSize.MS,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _yearController,
                  labelText: AnnualWithholdingLabels.chooseYear,
                  prefixIcon: CupertinoIcons.calendar,
                  readOnly: true,
                  onTap: _showYearPicker,
                  labelIcon: CupertinoIcons.calendar,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: CustomColors.background(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CupertinoColors.systemGrey.withAlpha(35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CustomColors.text(context).withAlpha(12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryAmountBlock(
                          label: AnnualWithholdingLabels.paymentAmount,
                          amountText: _numberFormatter.format(_totalPaymentAmount),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryAmountBlock(
                          label: AnnualWithholdingLabels.incomeTaxAmount,
                          amountText: _numberFormatter.format(_totalTaxAmount),
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: AnnualWithholdingLabels.addNew,
                    onPressed: () => _showEditor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: CustomText(
                text: '登録一覧',
                textSize: TextSize.MS,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: const Center(
                  child: EmptyStateView(
                    message: AnnualWithholdingLabels.emptyState,
                    icon: CupertinoIcons.collections,
                  ),
                ),
              )
            else
              ...items.map((item) {
                final isExpanded = _expandedCards[item.id] ?? false;
                final ext = item as dynamic;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomColors.background(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CupertinoColors.systemGrey.withAlpha(35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CustomColors.text(context).withAlpha(12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ヘッダー（支払い元名 ＆ 編集・削除ボタン）
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CustomColors.thema.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  CupertinoIcons.building_2_fill,
                                  size: 16,
                                  color: CustomColors.thema,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomText(
                                text: _paymentSourceName(item.paymentSourceId),
                                textSize: TextSize.MS,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // 編集ボタン
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _showEditor(existing: item),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: CustomColors.thema.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.pencil_circle_fill,
                                    size: 16,
                                    color: CustomColors.thema,
                                  ),
                                ),
                              ),
                              // 削除ボタン
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _confirmDelete(item.id),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: CustomColors.negative.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.trash,
                                    size: 16,
                                    color: CustomColors.negative,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 基本の金額ブロック（支払金額 ＆ 源泉徴収税額）
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryAmountBlock(
                              label: AnnualWithholdingLabels.paymentAmount,
                              amountText: _numberFormatter.format(item.paymentAmount),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryAmountBlock(
                              label: AnnualWithholdingLabels.incomeTaxAmount,
                              amountText: _numberFormatter.format(item.incomeTaxAmount),
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),

                      // 展開時のみ表示される詳細項目ブロック
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: CupertinoColors.systemGrey3),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryAmountBlock(
                                label: AnnualWithholdingLabels.deductionAmount,
                                amountText: _numberFormatter.format(item.deductionAmount),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryAmountBlock(
                                label: AnnualWithholdingLabels.exemptionAmount,
                                amountText: _numberFormatter.format(item.totalExemptionAmount),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryAmountBlock(
                                label: '社会保険料等の金額',
                                amountText: _numberFormatter.format(ext.socialInsuranceAmount ?? 0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryAmountBlock(
                                label: '生命保険料の控除額',
                                amountText: _numberFormatter.format(ext.lifeInsuranceDeduction ?? 0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryAmountBlock(
                                label: '地震保険料の控除額',
                                amountText: _numberFormatter.format(ext.earthquakeInsuranceDeduction ?? 0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryAmountBlock(
                                label: '配偶者（特別）控除の額',
                                amountText: _numberFormatter.format(ext.spouseDeductionAmount ?? 0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryAmountBlock(
                                label: '住宅借入金等特別控除の額',
                                amountText: _numberFormatter.format(ext.housingLoanDeduction ?? 0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        if (item.memo.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey.withAlpha(10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomText(
                              text: 'メモ: ${item.memo}',
                              textSize: TextSize.SS,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 8),

                      // 開閉トグルボタン
                      Center(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _expandedCards[item.id] = !isExpanded;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomText(
                                text: isExpanded ? '詳細を閉じる' : '詳細を表示',
                                textSize: TextSize.SS,
                                color: CustomColors.thema,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                isExpanded
                                    ? CupertinoIcons.chevron_up
                                    : CupertinoIcons.chevron_down,
                                size: 14,
                                color: CustomColors.thema,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SummaryAmountBlock extends StatelessWidget {
  final String label;
  final String amountText;
  final bool isPrimary;

  const _SummaryAmountBlock({
    required this.label,
    required this.amountText,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            textSize: TextSize.SS,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                CustomText(
                  text: amountText,
                  textSize: TextSize.MS,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? CustomColors.thema : CustomColors.text(context),
                ),
                const SizedBox(width: 2),
                CustomText(
                  text: AnnualWithholdingLabels.yenSuffix,
                  textSize: TextSize.SS,
                  fontWeight: FontWeight.bold,
                  color: (isPrimary ? CustomColors.thema : CustomColors.text(context)).withAlpha(180),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}