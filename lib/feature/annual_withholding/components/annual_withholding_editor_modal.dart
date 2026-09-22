import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/custom_action_picker.dart';
import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_withholding/domain/annual_withholding_labels.dart';
import 'package:salary/feature/payment_source/input/input_payment_source_view.dart';

class AnnualWithholdingEditorModal extends ConsumerStatefulWidget {
  final AnnualWithholding? existing;
  final int selectedYear;
  final List<PaymentSource> paymentSources;
  final bool Function(AnnualWithholding item) onSaved;

  const AnnualWithholdingEditorModal({
    super.key,
    this.existing,
    required this.selectedYear,
    required this.paymentSources,
    required this.onSaved,
  });

  @override
  ConsumerState<AnnualWithholdingEditorModal> createState() =>
      _AnnualWithholdingEditorModalState();
}

class _AnnualWithholdingEditorModalState
    extends ConsumerState<AnnualWithholdingEditorModal> {
  final _numberFormatter = NumberFormat('#,###');
  late int _selectedSourceIndex;

  late final TextEditingController _paymentSourceController;
  late final TextEditingController _paymentAmountController;
  late final TextEditingController _deductionAmountController;
  late final TextEditingController _exemptionAmountController;
  late final TextEditingController _taxAmountController;
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    final sourceIndex = widget.paymentSources.indexWhere(
          (source) => source.id == (widget.existing?.paymentSourceId ?? widget.paymentSources.first.id),
    );
    _selectedSourceIndex = sourceIndex >= 0 ? sourceIndex : 0;

    _paymentSourceController = TextEditingController(
      text: widget.paymentSources[_selectedSourceIndex].name,
    );
    _paymentAmountController = TextEditingController(
      text: widget.existing != null && widget.existing!.paymentAmount > 0
          ? _numberFormatter.format(widget.existing!.paymentAmount)
          : '',
    );
    _deductionAmountController = TextEditingController(
      text: widget.existing != null && widget.existing!.deductionAmount > 0
          ? _numberFormatter.format(widget.existing!.deductionAmount)
          : '',
    );
    _exemptionAmountController = TextEditingController(
      text: widget.existing != null && widget.existing!.totalExemptionAmount > 0
          ? _numberFormatter.format(widget.existing!.totalExemptionAmount)
          : '',
    );
    _taxAmountController = TextEditingController(
      text: widget.existing != null && widget.existing!.incomeTaxAmount > 0
          ? _numberFormatter.format(widget.existing!.incomeTaxAmount)
          : '',
    );
    _memoController = TextEditingController(text: widget.existing?.memo ?? '');
  }

  @override
  void dispose() {
    _paymentSourceController.dispose();
    _paymentAmountController.dispose();
    _deductionAmountController.dispose();
    _exemptionAmountController.dispose();
    _taxAmountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  int _parseNumber(TextEditingController controller) {
    return int.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
  }

  /// 支払い元追加画面を表示
  Future<void> _showInputPaymentSourceModal(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const InputPaymentSourceView();
      },
    );
  }

  /// 支払い元ピッカー
  Widget _paymentSourcePicker({
    required Color prefixIconColor,
    required VoidCallback onTapped,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: CustomTextField(
            controller: _paymentSourceController,
            labelText: '支払い元',
            prefixIcon: CupertinoIcons.building_2_fill,
            prefixIconColor: prefixIconColor,
            readOnly: true,
            onTap: onTapped,
            suffix: SizedBox(
              child: IconButton(
                onPressed: () => _showInputPaymentSourceModal(context),
                icon: const Icon(CupertinoIcons.add_circled_solid, size: 28),
              ),
            ),
            labelIcon: CupertinoIcons.building_2_fill,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSources = widget.paymentSources;
    final selectedSource = currentSources.isNotEmpty
        ? currentSources[_selectedSourceIndex]
        : null;

    // 選択中の支払い元のカラーを取得（定義されていない場合はデフォルトのグレー）
    final prefixIconColor =
        selectedSource?.themaColorEnum.color ?? CupertinoColors.systemGrey;

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: CupertinoNavigationBar(
        middle: CustomText(
          text: widget.existing == null ? '源泉徴収の追加' : '源泉徴収の編集',
          fontWeight: FontWeight.bold,
          textSize: TextSize.MS,
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const CustomText(
            text: AnnualWithholdingLabels.cancel,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final validSource = currentSources[_selectedSourceIndex];
            final item = AnnualWithholding(
              widget.existing?.id ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              widget.selectedYear,
              validSource.id,
              _parseNumber(_paymentAmountController),
              _parseNumber(_deductionAmountController),
              _parseNumber(_exemptionAmountController),
              _parseNumber(_taxAmountController),
              _memoController.text.trim(),
              widget.existing?.createdAt ?? DateTime.now(),
            );

            final isSuccess = widget.onSaved(item);
            if (isSuccess) {
              Navigator.of(context).pop();
            }
          },
          child: const CustomText(
            text: AnnualWithholdingLabels.save,
            color: CustomColors.thema,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paymentSourcePicker(
                prefixIconColor: prefixIconColor,
                onTapped: () async {
                  final paymentSources = widget.paymentSources;

                  if (paymentSources.isEmpty) {
                    _showInputPaymentSourceModal(context);
                  } else {
                    CustomActionPicker.show<PaymentSource>(
                      context: context,
                      title: '支払い元を選択してください',
                      items: paymentSources,
                      currentValue: selectedSource,
                      labelBuilder: (source) => source.name,
                      onSelected: (source) {
                        setState(() {
                          _selectedSourceIndex = paymentSources.indexOf(source);
                          _paymentSourceController.text = source.name;
                        });
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _paymentAmountController,
                labelText: AnnualWithholdingLabels.paymentAmount,
                prefixIcon: CupertinoIcons.money_yen,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.money_yen_circle,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _deductionAmountController,
                labelText: AnnualWithholdingLabels.deductionAmount,
                prefixIcon: CupertinoIcons.arrow_down_right_circle,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.arrow_down_right_circle,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _exemptionAmountController,
                labelText: AnnualWithholdingLabels.exemptionAmount,
                prefixIcon: CupertinoIcons.minus_circle,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.minus_circle,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _taxAmountController,
                labelText: AnnualWithholdingLabels.incomeTaxAmount,
                prefixIcon: CupertinoIcons.doc_checkmark,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.doc_checkmark,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _memoController,
                labelText: AnnualWithholdingLabels.placeholderMemo,
                prefixIcon: CupertinoIcons.text_alignleft,
                maxLines: 3,
                labelIcon: CupertinoIcons.text_alignleft,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}