
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/charts/chart_salary_view_model.dart';
import 'package:salary/common/components/custom_label_view.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/utilities/number_utils.dart';

/// 当年 / 前年比較テーブル
class TableSalaryInfoView extends ConsumerWidget {

  const TableSalaryInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(chartSalaryProvider.notifier);

    final selectedSource = ref.watch(chartSalaryProvider.select((s) => s.selectedSource));
    final selectedYear = ref.watch(chartSalaryProvider.select((s) => s.selectedYear));
    final allSalaries = ref.watch(chartSalaryProvider.select((s) => s.allSalaries));

    final summary = vm.buildYearlySummary(
      selectedSource: selectedSource,
      selectedYear: selectedYear,
      allSalaries: allSalaries,
    );


    return Column(
      spacing: 20,
      children: [
        _buildSalaryRow(
          context,
          '年収（総支給）',
          summary.paymentAmount,
          diff: summary.diffPaymentAmount,
        ),
        _buildSalaryRow(
          context,
          '年収（手取り）',
          summary.netSalary,
          diff: summary.diffNetSalary,
        ),
        _buildSalaryRow(
          context,
          '夏季賞与（総支給）',
          summary.summerBonus,
          diff: summary.diffSummerBonus,
        ),
        _buildSalaryRow(
          context,
          '冬季賞与（総支給）',
          summary.winterBonus,
          diff: summary.diffWinterBonus,
        ),
      ],
    );
  }

  Widget _buildSalaryRow(
      BuildContext context,
      String label,
      int amount, {int diff = 0}) {
    Color diffColor;
    String diffText = '';

    if (diff > 0) {
      diffColor = Colors.green;
      diffText = '+${NumberUtils.formatWithComma(diff)}円';
    } else if (diff < 0) {
      diffColor = Colors.red;
      diffText = '${NumberUtils.formatWithComma(diff)}円';
    } else {
      diffColor = CustomColors.text(context).withAlpha(120);
      diffText = '±0';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomLabelView(labelText: label),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: NumberUtils.formatWithComma(amount),
                  textSize: TextSize.L,
                  color: CustomColors.thema,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(width: 5),
                const CustomText(text: '円', textSize: TextSize.S),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Spacer(),
            const CustomText(text: '前年', textSize: TextSize.SS),
            const SizedBox(width: 5),
            CustomText(
              text: diffText,
              textSize: TextSize.SS,
              color: diffColor,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ],
    );
  }
}