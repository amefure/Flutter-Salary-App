import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/settings/annual_target_view_model.dart';
import 'package:salary/feature/settings/domain/annual_target_labels.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _yearController.text = '$_selectedYear${AnnualTargetLabels.yearSuffix}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _yearController.dispose();
    super.dispose();
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
          height: 300,
          color: CustomColors.background(context),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  child: const CustomText(text: AnnualTargetLabels.pickerDone),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectYear(years[selectedIndex]);
                  },
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setPickerState) {
                    return CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: pickerIndex,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setPickerState(() => selectedIndex = index);
                      },
                      children: [
                        for (final year in years)
                          Center(
                            child: CustomText(
                              text: '$year${AnnualTargetLabels.yearSuffix}',
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

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(
      annualTargetProvider.select((state) => state.targets),
    );
    final isSaving = ref.watch(
      annualTargetProvider.select((state) => state.isSaving),
    );
    final selectedTarget =
        targets.where((target) => target.year == _selectedYear).firstOrNull;
    if (_amountController.text.isEmpty && selectedTarget != null) {
      _amountController.text = _amountFormatter.format(
        selectedTarget.targetAmount,
      );
    }

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
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomColors.background(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: AnnualTargetLabels.formHeading,
                    textSize: TextSize.L,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _yearController,
                    labelText: AnnualTargetLabels.targetYear,
                    prefixIcon: CupertinoIcons.calendar,
                    readOnly: true,
                    onTap: _showYearPicker,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _amountController,
                    labelText: AnnualTargetLabels.targetAmount,
                    prefixIcon: CupertinoIcons.money_yen_circle_fill,
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: CustomText(text: AnnualTargetLabels.yenSuffix),
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    CustomText(
                      text: _errorMessage!,
                      color: CustomColors.negative,
                      textSize: TextSize.S,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: CustomElevatedButton(
                      text: AnnualTargetLabels.save,
                      onPressed: isSaving ? () {} : _save,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: CustomText(
                text: AnnualTargetLabels.history,
                textSize: TextSize.L,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (targets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CustomText(text: AnnualTargetLabels.emptyHistory),
                ),
              )
            else
              ...targets.map(
                (target) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.background(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: '${target.year}${AnnualTargetLabels.yearSuffix}',
                        fontWeight: FontWeight.bold,
                      ),
                      CustomText(
                        text:
                            '${_amountFormatter.format(target.targetAmount)}'
                            '${AnnualTargetLabels.yenSuffix}',
                        fontWeight: FontWeight.bold,
                        color: CustomColors.thema,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
