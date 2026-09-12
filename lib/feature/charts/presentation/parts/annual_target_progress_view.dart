import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_target/domain/annual_target_labels.dart';
import 'package:salary/feature/charts/domain/annual_target_calculator.dart';
import 'package:salary/feature/annual_target/annual_target_screen.dart';
import 'package:salary/feature/annual_target/annual_target_view_model.dart';

class AnnualTargetProgressView extends ConsumerWidget {
  final List<Salary> salaries;

  const AnnualTargetProgressView({super.key, required this.salaries});

  String _formatAmount(int amount) =>
      '${NumberFormat('#,###').format(amount)}${AnnualTargetLabels.yenSuffix}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentYear = DateTime.now().year;
    final targets = ref.watch(
      annualTargetProvider.select((state) => state.targets),
    );
    final target =
        targets.where((item) => item.year == currentYear).firstOrNull;

    if (target == null) {
      return _UnsetTargetView();
    }

    final progress = const AnnualTargetCalculator().calculate(
      target: target,
      salaries: salaries,
    );
    return _ProgressCard(progress: progress, formatAmount: _formatAmount);
  }
}

class _UnsetTargetView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.systemGrey.withAlpha(35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColors.text(context).withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomColors.thema.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CupertinoIcons.flag,
              size: 20,
              color: CustomColors.thema,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: CustomText(
              text: AnnualTargetLabels.unset,
              textSize: TextSize.S,
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: CustomColors.thema.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const AnnualTargetScreen(),
                ),
              );
            },
            child: const CustomText(
              text: AnnualTargetLabels.setTarget,
              textSize: TextSize.S,
              color: CustomColors.thema,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final AnnualTargetProgress progress;
  final String Function(int) formatAmount;

  const _ProgressCard({required this.progress, required this.formatAmount});

  @override
  Widget build(BuildContext context) {
    // 100%超えを判定
    final bool isCompleted = progress.achievementPercent >= 100.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? CustomColors.thema.withAlpha(100)
              : CupertinoColors.systemGrey.withAlpha(35),
          width: isCompleted ? 1.5 : 1,
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
          // ヘッダー（タイトル ＆ 達成率バッジ）
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
                    text: isCompleted ? '目標達成！' : AnnualTargetLabels.progressTitle,
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
                  text: '${progress.achievementPercent}%',
                  textSize: TextSize.MS,
                  color: isCompleted ? CupertinoColors.white : CustomColors.thema,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // プログレスバー（100%超えのときはバーもリッチに表現）
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clampedProgress,
              minHeight: 8,
              backgroundColor: CupertinoColors.systemGrey.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(
                CustomColors.thema,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 金額情報を2カラムのブロックに分割
          Row(
            children: [
              Expanded(
                child: _AmountBlock(
                  label: AnnualTargetLabels.target,
                  formattedValue: formatAmount(progress.targetAmount),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountBlock(
                  label: AnnualTargetLabels.actual,
                  formattedValue: formatAmount(progress.actualAmount),
                  isPrimary: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AmountBlock(
                  label: AnnualTargetLabels.forecast,
                  formattedValue: formatAmount(progress.projectedAmount),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountBlock(
                  label: AnnualTargetLabels.remaining,
                  formattedValue: formatAmount(progress.remainingAmount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  final String label;
  final String formattedValue; // 例: "5,000,000円"
  final bool isPrimary;

  const _AmountBlock({
    required this.label,
    required this.formattedValue,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    // 金額の数字部分と「円」の単位部分を分解してサイズを調整する
    final isYenEnd = formattedValue.endsWith('円');
    final numberPart = isYenEnd
        ? formattedValue.substring(0, formattedValue.length - 1)
        : formattedValue;

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
                  text: numberPart,
                  textSize: TextSize.MS,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? CustomColors.thema : CustomColors.text(context),
                ),
                if (isYenEnd) ...[
                  const SizedBox(width: 2),
                  CustomText(
                    text: '円',
                    textSize: TextSize.SS, // 円単位だけ少し小さく
                    fontWeight: FontWeight.bold,
                    color: (isPrimary ? CustomColors.thema : CustomColors.text(context)).withAlpha(180),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}