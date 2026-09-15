import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_withholding/annual_withholding_view_model.dart';
import 'package:salary/feature/annual_withholding/domain/annual_withholding_labels.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  List<AnnualWithholding> get _itemsForSelectedYear {
    final state = ref.read(annualWithholdingProvider);
    final items =
        state.items.where((item) => item.year == _selectedYear).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<PaymentSource> get _paymentSources {
    return ref.read(annualWithholdingProvider).paymentSources;
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

  int _parseNumber(TextEditingController controller) {
    return int.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
  }

  Future<void> _showYearPicker() async {
    final years = List<int>.generate(
      31,
      (index) => DateTime.now().year - 15 + index,
    );
    var selectedIndex = years.indexOf(_selectedYear);
    if (selectedIndex < 0) {
      selectedIndex = years.length ~/ 2;
    }

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        var pickerIndex = selectedIndex;
        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: CustomColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.zero,
                      child: CustomText(
                        text: AnnualWithholdingLabels.chooseYear,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() => _selectedYear = years[pickerIndex]);
                      },
                      child: const CustomText(
                        text: AnnualWithholdingLabels.pickerDone,
                        color: CustomColors.thema,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 44,
                  onSelectedItemChanged: (index) {
                    pickerIndex = index;
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
      await showCupertinoDialog<void>(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text(AnnualWithholdingLabels.paymentSource),
              content: const Text('まずは支払い元を登録してください。'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final sourceIndex = sources.indexWhere(
      (source) => source.id == (existing?.paymentSourceId ?? sources.first.id),
    );
    var selectedSourceIndex = sourceIndex >= 0 ? sourceIndex : 0;

    final paymentAmountController = TextEditingController(
      text:
          existing != null && existing.paymentAmount > 0
              ? _numberFormatter.format(existing.paymentAmount)
              : '',
    );
    final deductionAmountController = TextEditingController(
      text:
          existing != null && existing.deductionAmount > 0
              ? _numberFormatter.format(existing.deductionAmount)
              : '',
    );
    final exemptionAmountController = TextEditingController(
      text:
          existing != null && existing.totalExemptionAmount > 0
              ? _numberFormatter.format(existing.totalExemptionAmount)
              : '',
    );
    final taxAmountController = TextEditingController(
      text:
          existing != null && existing.incomeTaxAmount > 0
              ? _numberFormatter.format(existing.incomeTaxAmount)
              : '',
    );
    final memoController = TextEditingController(text: existing?.memo ?? '');

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomColors.background(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const CustomText(
                            text: AnnualWithholdingLabels.cancel,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            final selectedSource = sources[selectedSourceIndex];
                            final item = AnnualWithholding(
                              existing?.id ??
                                  DateTime.now().microsecondsSinceEpoch
                                      .toString(),
                              _selectedYear,
                              selectedSource.id,
                              _parseNumber(paymentAmountController),
                              _parseNumber(deductionAmountController),
                              _parseNumber(exemptionAmountController),
                              _parseNumber(taxAmountController),
                              memoController.text.trim(),
                              existing?.createdAt ?? DateTime.now(),
                            );

                            final isSaved = ref
                                .read(annualWithholdingProvider.notifier)
                                .save(item: item);
                            if (!isSaved) {
                              Navigator.of(context).pop();
                              showCupertinoDialog<void>(
                                context: context,
                                builder:
                                    (context) => CupertinoAlertDialog(
                                      title: const Text('登録エラー'),
                                      content: const Text(
                                        AnnualWithholdingLabels
                                            .duplicateWarning,
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                              return;
                            }

                            Navigator.of(context).pop();
                          },
                          child: const CustomText(
                            text: AnnualWithholdingLabels.save,
                            color: CustomColors.thema,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 160,
                      child: CupertinoPicker(
                        itemExtent: 44,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedSourceIndex,
                        ),
                        onSelectedItemChanged: (index) {
                          setModalState(() => selectedSourceIndex = index);
                        },
                        children: [
                          for (final source in sources)
                            Center(
                              child: CustomText(
                                text: source.name,
                                textSize: TextSize.MS,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _amountField(
                      controller: paymentAmountController,
                      label: AnnualWithholdingLabels.paymentAmount,
                    ),
                    const SizedBox(height: 12),
                    _amountField(
                      controller: deductionAmountController,
                      label: AnnualWithholdingLabels.deductionAmount,
                    ),
                    const SizedBox(height: 12),
                    _amountField(
                      controller: exemptionAmountController,
                      label: AnnualWithholdingLabels.exemptionAmount,
                    ),
                    const SizedBox(height: 12),
                    _amountField(
                      controller: taxAmountController,
                      label: AnnualWithholdingLabels.incomeTaxAmount,
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: memoController,
                      placeholder: AnnualWithholdingLabels.placeholderMemo,
                      minLines: 2,
                      maxLines: 3,
                      padding: const EdgeInsets.all(12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _amountField({
    required TextEditingController controller,
    required String label,
  }) {
    return Row(
      children: [
        Expanded(flex: 2, child: CustomText(text: label)),
        Expanded(
          flex: 3,
          child: CupertinoTextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            placeholder: '0',
          ),
        ),
      ],
    );
  }

  void _confirmDelete(String id) {
    showCupertinoDialog<void>(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text(AnnualWithholdingLabels.delete),
            content: const Text(AnnualWithholdingLabels.deleteConfirm),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AnnualWithholdingLabels.cancel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(annualWithholdingProvider.notifier).deleteById(id);
                },
                child: const Text(AnnualWithholdingLabels.delete),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(annualWithholdingProvider);
    final items =
        state.items.where((item) => item.year == _selectedYear).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomColors.background(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText(
                        text: AnnualWithholdingLabels.summaryTitle,
                        fontWeight: FontWeight.bold,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _showYearPicker,
                        child: CustomText(
                          text:
                              '$_selectedYear${AnnualWithholdingLabels.yearSuffix}',
                          color: CustomColors.thema,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryItem(
                          AnnualWithholdingLabels.totalPayment,
                          _totalPaymentAmount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _summaryItem(
                          AnnualWithholdingLabels.totalTax,
                          _totalTaxAmount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: AnnualWithholdingLabels.screenTitle,
                  fontWeight: FontWeight.bold,
                ),
                CupertinoButton.filled(
                  onPressed: () => _showEditor(),
                  child: const CustomText(
                    text: AnnualWithholdingLabels.addNew,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CustomColors.background(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CustomText(text: AnnualWithholdingLabels.emptyState),
                ),
              )
            else
              ...items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: CustomColors.background(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CupertinoListSection.insetGrouped(
                    backgroundColor: CustomColors.foundation(context),
                    margin: EdgeInsets.zero,
                    children: [
                      CupertinoListTile(
                        title: CustomText(
                          text:
                              '${AnnualWithholdingLabels.paymentSource}: ${_paymentSourceName(item.paymentSourceId)}',
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: CustomText(
                          text:
                              '${AnnualWithholdingLabels.paymentAmount}: ${_numberFormatter.format(item.paymentAmount)}${AnnualWithholdingLabels.yenSuffix}',
                        ),
                        additionalInfo: CustomText(
                          text:
                              '${_numberFormatter.format(item.incomeTaxAmount)}${AnnualWithholdingLabels.yenSuffix}',
                          color: CustomColors.thema,
                          fontWeight: FontWeight.bold,
                        ),
                        leading: const Icon(CupertinoIcons.doc_text_fill),
                        onTap: () => _showEditor(existing: item),
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _confirmDelete(item.id),
                          child: const Icon(
                            CupertinoIcons.delete_simple,
                            color: CustomColors.negative,
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

  Widget _summaryItem(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomColors.foundation(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, textSize: TextSize.SS),
          const SizedBox(height: 6),
          CustomText(
            text:
                '${_numberFormatter.format(value)}${AnnualWithholdingLabels.yenSuffix}',
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
