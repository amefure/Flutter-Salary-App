import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_withholding/domain/annual_withholding_labels.dart';

class AnnualWithholdingSummaryCard extends StatelessWidget {
  final int selectedYear;
  final int totalPaymentAmount;
  final int totalTaxAmount;
  final VoidCallback onTapYear;

  const AnnualWithholdingSummaryCard({
    super.key,
    required this.selectedYear,
    required this.totalPaymentAmount,
    required this.totalTaxAmount,
    required this.onTapYear,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey.withAlpha(35),
          width: 1,
        ),
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
                textSize: TextSize.MS,
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTapYear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.thema.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomText(
                    text: '$selectedYear${AnnualWithholdingLabels.yearSuffix}',
                    color: CustomColors.thema,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  context,
                  AnnualWithholdingLabels.totalPayment,
                  totalPaymentAmount,
                  numberFormatter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryItem(
                  context,
                  AnnualWithholdingLabels.totalTax,
                  totalTaxAmount,
                  numberFormatter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
      BuildContext context, String label, int value, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CustomColors.foundation(context),
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
                  text: formatter.format(value),
                  fontWeight: FontWeight.bold,
                  textSize: TextSize.MS,
                ),
                const SizedBox(width: 2),
                const CustomText(
                  text: AnnualWithholdingLabels.yenSuffix,
                  textSize: TextSize.SS,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}