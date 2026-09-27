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
  bool _showDetails = false; // 詳細入力欄の表示状態

  // 基本コントロール
  late final TextEditingController _paymentSourceController;
  late final TextEditingController _paymentAmountController;
  late final TextEditingController _deductionAmountController;
  late final TextEditingController _exemptionAmountController;
  late final TextEditingController _taxAmountController;
  late final TextEditingController _memoController;

  // 詳細コントロール
  late final TextEditingController _socialInsuranceController;
  late final TextEditingController _lifeInsuranceController;
  late final TextEditingController _earthquakeInsuranceController;
  late final TextEditingController _spouseDeductionController;
  late final TextEditingController _housingLoanController;

  @override
  void initState() {
    super.initState();
    int sourceIndex = -1;
    if (widget.existing != null && widget.existing!.paymentSourceId.isNotEmpty) {
      sourceIndex = widget.paymentSources.indexWhere(
            (source) => source.id == widget.existing!.paymentSourceId,
      );
    }
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

    // 詳細項目の初期化
    _socialInsuranceController = TextEditingController(
      text: (widget.existing != null && (widget.existing as dynamic).socialInsuranceAmount > 0)
          ? _numberFormatter.format((widget.existing as dynamic).socialInsuranceAmount)
          : '',
    );
    _lifeInsuranceController = TextEditingController(
      text: (widget.existing != null && (widget.existing as dynamic).lifeInsuranceDeduction > 0)
          ? _numberFormatter.format((widget.existing as dynamic).lifeInsuranceDeduction)
          : '',
    );
    _earthquakeInsuranceController = TextEditingController(
      text: (widget.existing != null && (widget.existing as dynamic).earthquakeInsuranceDeduction > 0)
          ? _numberFormatter.format((widget.existing as dynamic).earthquakeInsuranceDeduction)
          : '',
    );
    _spouseDeductionController = TextEditingController(
      text: (widget.existing != null && (widget.existing as dynamic).spouseDeductionAmount > 0)
          ? _numberFormatter.format((widget.existing as dynamic).spouseDeductionAmount)
          : '',
    );
    _housingLoanController = TextEditingController(
      text: (widget.existing != null && (widget.existing as dynamic).housingLoanDeduction > 0)
          ? _numberFormatter.format((widget.existing as dynamic).housingLoanDeduction)
          : '',
    );

    // 既存データに詳細データの入力値があれば、最初から詳細を開いておく
    if (widget.existing != null) {
      final ext = widget.existing as dynamic;
      if ((ext.socialInsuranceAmount ?? 0) > 0 ||
          (ext.lifeInsuranceDeduction ?? 0) > 0 ||
          (ext.earthquakeInsuranceDeduction ?? 0) > 0 ||
          (ext.spouseDeductionAmount ?? 0) > 0 ||
          (ext.housingLoanDeduction ?? 0) > 0) {
        _showDetails = true;
      }
    }
  }

  @override
  void dispose() {
    _paymentSourceController.dispose();
    _paymentAmountController.dispose();
    _deductionAmountController.dispose();
    _exemptionAmountController.dispose();
    _taxAmountController.dispose();
    _memoController.dispose();
    _socialInsuranceController.dispose();
    _lifeInsuranceController.dispose();
    _earthquakeInsuranceController.dispose();
    _spouseDeductionController.dispose();
    _housingLoanController.dispose();
    super.dispose();
  }

  int _parseNumber(TextEditingController controller) {
    return int.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentSources = widget.paymentSources;
    final selectedSource = currentSources.isNotEmpty
        ? currentSources[_selectedSourceIndex]
        : null;

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
              _parseNumber(_socialInsuranceController),
              _parseNumber(_lifeInsuranceController),
              _parseNumber(_earthquakeInsuranceController),
              _parseNumber(_spouseDeductionController),
              _parseNumber(_housingLoanController),
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
              // 支払い元選択
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _paymentSourceController,
                      labelText: '支払い元',
                      prefixIcon: CupertinoIcons.building_2_fill,
                      prefixIconColor: prefixIconColor,
                      readOnly: true,
                      onTap: () async {
                        final paymentSources = widget.paymentSources;
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
                      },
                      labelIcon: CupertinoIcons.building_2_fill,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 支払金額
              CustomTextField(
                controller: _paymentAmountController,
                labelText: AnnualWithholdingLabels.paymentAmount,
                prefixIcon: CupertinoIcons.money_yen,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.money_yen_circle,
              ),
              const SizedBox(height: 12),

              // 給与所得控除後の金額
              CustomTextField(
                controller: _deductionAmountController,
                labelText: AnnualWithholdingLabels.deductionAmount,
                prefixIcon: CupertinoIcons.arrow_down_right_circle,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.arrow_down_right_circle,
              ),
              const SizedBox(height: 12),

              // 所得控除の額の合計額
              CustomTextField(
                controller: _exemptionAmountController,
                labelText: AnnualWithholdingLabels.exemptionAmount,
                prefixIcon: CupertinoIcons.minus_circle,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.minus_circle,
              ),
              const SizedBox(height: 12),

              // 源泉徴収税額
              CustomTextField(
                controller: _taxAmountController,
                labelText: AnnualWithholdingLabels.incomeTaxAmount,
                prefixIcon: CupertinoIcons.doc_checkmark,
                keyboardType: TextInputType.number,
                labelIcon: CupertinoIcons.doc_checkmark,
              ),
              const SizedBox(height: 20),

              // --- 詳細入力欄の開閉ボタン ---
              Center(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: _showDetails ? '詳細を閉じる' : '詳細に入力する',
                        color: CustomColors.thema,
                        fontWeight: FontWeight.bold,
                        textSize: TextSize.MS,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showDetails ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                        color: CustomColors.thema,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- 詳細入力セクション（基本入力と同じ並びのUI） ---
              if (_showDetails) ...[
                CustomTextField(
                  controller: _socialInsuranceController,
                  labelText: '社会保険料等の金額',
                  prefixIcon: CupertinoIcons.shield_lefthalf_fill,
                  keyboardType: TextInputType.number,
                  labelIcon: CupertinoIcons.shield_lefthalf_fill,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _lifeInsuranceController,
                  labelText: '生命保険料の控除額',
                  prefixIcon: CupertinoIcons.heart_fill,
                  keyboardType: TextInputType.number,
                  labelIcon: CupertinoIcons.heart_fill,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _earthquakeInsuranceController,
                  labelText: '地震保険料の控除額',
                  prefixIcon: CupertinoIcons.house_fill,
                  keyboardType: TextInputType.number,
                  labelIcon: CupertinoIcons.house_fill,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _spouseDeductionController,
                  labelText: '配偶者（特別）控除の額',
                  prefixIcon: CupertinoIcons.person_2_fill,
                  keyboardType: TextInputType.number,
                  labelIcon: CupertinoIcons.person_2_fill,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _housingLoanController,
                  labelText: '住宅借入金等特別控除の額',
                  prefixIcon: CupertinoIcons.building_2_fill,
                  keyboardType: TextInputType.number,
                  labelIcon: CupertinoIcons.building_2_fill,
                ),
                const SizedBox(height: 20),
              ],

              // メモ欄
              CustomTextField(
                controller: _memoController,
                labelText: AnnualWithholdingLabels.placeholderMemo,
                prefixIcon: CupertinoIcons.text_alignleft,
                maxLines: 3,
                keyboardType: TextInputType.text,
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