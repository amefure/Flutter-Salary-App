import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_target/annual_target_view_model.dart';
import 'package:salary/feature/annual_target/domain/annual_target_labels.dart';

class AnnualTargetScreen extends ConsumerStatefulWidget {
  const AnnualTargetScreen({super.key});

  @override
  ConsumerState<AnnualTargetScreen> createState() => _AnnualTargetScreenState();
}

class _AnnualTargetScreenState extends ConsumerState<AnnualTargetScreen> {
  final _amountController = TextEditingController();
  final _yearController = TextEditingController();
  final _amountFormatter = NumberFormat('#,###');
  late int _selectedYear;
  String? _errorMessage;
  bool _hasInputContent = false;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _yearController.text = '$_selectedYear${AnnualTargetLabels.yearSuffix}';
    _amountController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateInput);
    _amountController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _amountController.text.replaceAll(',', '').trim();
    final amount = int.tryParse(text);
    final isValid = amount != null && amount > 0;
    if (_hasInputContent != isValid) {
      setState(() {
        _hasInputContent = isValid;
      });
    }
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
      _yearController.text = '$year${AnnualTargetLabels.yearSuffix}';
      final target = ref
          .read(annualTargetProvider.notifier)
          .targetForYear(year);
      _amountController.text =
      target == null ? '' : _amountFormatter.format(target.targetAmount);
      _errorMessage = null;
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
                        text: AnnualTargetLabels.pickerDone,
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
                              text: '$year${AnnualTargetLabels.yearSuffix}',
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

  void _save() {
    final amount = int.tryParse(
      _amountController.text.replaceAll(',', '').trim(),
    );
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = AnnualTargetLabels.invalidAmount);
      return;
    }

    final saved = ref
        .read(annualTargetProvider.notifier)
        .saveTarget(year: _selectedYear, targetAmount: amount);
    if (!saved) {
      setState(() => _errorMessage = AnnualTargetLabels.invalidAmount);
      return;
    }
    setState(() => _errorMessage = null);
    FocusScope.of(context).unfocus();
  }

  // 削除処理と確認ダイアログ
  void _confirmAndDelete() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('目標の削除'),
        content: Text('$_selectedYear 年の目標を削除しますか？'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(annualTargetProvider.notifier).deleteTarget(_selectedYear);
              // 削除後にフィールドをクリアして状態をリフレッシュ
              setState(() {
                _amountController.clear();
                _errorMessage = null;
              });
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(annualTargetProvider);
    final targets = state.targets;
    final isSaving = state.isSaving;

    final selectedTarget =
        targets.where((target) => target.year == _selectedYear).firstOrNull;

    if (_amountController.text.isEmpty && selectedTarget != null) {
      _amountController.text = _amountFormatter.format(
        selectedTarget.targetAmount,
      );
    }

    final bool isAlreadyExists = selectedTarget != null;
    final String saveButtonText = isAlreadyExists ? '更新する' : AnnualTargetLabels.save;

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: AnnualTargetLabels.screenTitle,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // フォーム入力セクション
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            CupertinoIcons.flag_fill,
                            size: 18,
                            color: CustomColors.thema,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CustomText(
                          text: isAlreadyExists ? '$_selectedYear年の目標を編集' : AnnualTargetLabels.formHeading,
                          textSize: TextSize.MS,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    if (isAlreadyExists)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: isSaving ? null : _confirmAndDelete,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CustomColors.negative.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.trash,
                            size: 18,
                            color: CustomColors.negative,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _yearController,
                  labelText: AnnualTargetLabels.targetYear,
                  prefixIcon: CupertinoIcons.calendar,
                  readOnly: true,
                  onTap: _showYearPicker,
                  labelIcon: CupertinoIcons.calendar,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _amountController,
                  labelText: AnnualTargetLabels.targetAmount,
                  prefixIcon: CupertinoIcons.money_yen,
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: CustomText(text: AnnualTargetLabels.yenSuffix),
                  ),
                  onSubmitted: (_) {
                    if (_hasInputContent) _save();
                  },
                  labelIcon: CupertinoIcons.money_yen_circle,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CustomColors.negative.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.exclamationmark_circle, size: 16, color: CustomColors.negative),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            text: _errorMessage!,
                            color: CustomColors.negative,
                            textSize: TextSize.S,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Opacity(
                    opacity: _hasInputContent ? 1.0 : 0.5,
                    child: CustomElevatedButton(
                      text: saveButtonText,
                      onPressed: (_hasInputContent && !isSaving) ? _save : () {},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 履歴セクションのタイトル
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: CustomText(
                text: AnnualTargetLabels.history,
                textSize: TextSize.MS,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 履歴リスト
            if (targets.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CustomColors.background(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CupertinoColors.systemGrey.withAlpha(30),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: CustomText(
                    text: AnnualTargetLabels.emptyHistory,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              )
            else
              ...targets.map((target) {
                final int actualAmount = ref
                    .read(annualTargetProvider.notifier)
                    .getActualAmountForYear(target.year);

                final double percent = target.targetAmount > 0
                    ? double.parse(((actualAmount / target.targetAmount) * 100).toStringAsFixed(1))
                    : 0.0;
                final double clampedProgress = target.targetAmount > 0
                    ? (actualAmount / target.targetAmount).clamp(0.0, 1.0)
                    : 0.0;

                final bool isCompleted = percent >= 100.0;
                final bool isSelected = target.year == _selectedYear;

                return GestureDetector(
                  onTap: () => _selectYear(target.year),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: CustomColors.background(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? CustomColors.thema.withAlpha(120) : CupertinoColors.systemGrey.withAlpha(35),
                        width: (isCompleted || isSelected) ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCompleted
                              ? CustomColors.thema.withAlpha(20)
                              : CustomColors.text(context).withAlpha(12),
                          blurRadius: isCompleted ? 16 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: CustomColors.thema.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isCompleted ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.flag,
                                    size: 16,
                                    color: CustomColors.thema,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CustomText(
                                  text: '${target.year}${AnnualTargetLabels.yearSuffix}',
                                  textSize: TextSize.MS,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: CustomColors.thema.withAlpha(isCompleted ? 255 : 25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomText(
                                text: '${percent == percent.toInt() ? percent.toInt() : percent}%',
                                textSize: TextSize.MS,
                                color: isCompleted ? CupertinoColors.white : CustomColors.thema,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: clampedProgress,
                            minHeight: 8,
                            backgroundColor: CupertinoColors.systemGrey.withAlpha(30),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              CustomColors.thema,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _HistoryAmountBlock(
                                label: AnnualTargetLabels.target,
                                amountText: _amountFormatter.format(target.targetAmount),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HistoryAmountBlock(
                                label: '実績',
                                amountText: _amountFormatter.format(actualAmount),
                                isPrimary: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _HistoryAmountBlock extends StatelessWidget {
  final String label;
  final String amountText;
  final bool isPrimary;

  const _HistoryAmountBlock({
    required this.label,
    required this.amountText,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey.withAlpha(isPrimary ? 20 : 10),
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
                  text: AnnualTargetLabels.yenSuffix,
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