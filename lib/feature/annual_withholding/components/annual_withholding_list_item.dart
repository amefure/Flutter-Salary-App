import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_withholding/domain/annual_withholding_labels.dart';

class AnnualWithholdingListItem extends StatelessWidget {
  final AnnualWithholding item;
  final String paymentSourceName;
  final NumberFormat numberFormatter;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AnnualWithholdingListItem({
    super.key,
    required this.item,
    required this.paymentSourceName,
    required this.numberFormatter,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey.withAlpha(35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomColors.thema.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.doc_text_fill,
              color: CustomColors.thema,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: paymentSourceName,
                    fontWeight: FontWeight.bold,
                    textSize: TextSize.MS,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text:
                    '支払金額: ${numberFormatter.format(item.paymentAmount)}${AnnualWithholdingLabels.yenSuffix}',
                    textSize: TextSize.S,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text:
                '${numberFormatter.format(item.incomeTaxAmount)}${AnnualWithholdingLabels.yenSuffix}',
                color: CustomColors.thema,
                fontWeight: FontWeight.bold,
                textSize: TextSize.MS,
              ),
              const SizedBox(height: 2),
              const CustomText(
                text: '所得税',
                textSize: TextSize.SS,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.trash,
                size: 14,
                color: CupertinoColors.systemRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}