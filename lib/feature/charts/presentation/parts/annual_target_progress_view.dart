import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/charts/domain/annual_target_calculator.dart';
import 'package:salary/feature/settings/annual_target_screen.dart';
import 'package:salary/feature/settings/annual_target_view_model.dart';
import 'package:salary/feature/settings/domain/annual_target_labels.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.flag,
            size: 22,
            color: CustomColors.thema.withAlpha(180),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: CustomText(
              text: AnnualTargetLabels.unset,
              textSize: TextSize.S,
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColors.text(context).withAlpha(18),
            blurRadius: 12,
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
              const CustomText(
                text: AnnualTargetLabels.progressTitle,
                textSize: TextSize.ML,
                fontWeight: FontWeight.bold,
              ),
              CustomText(
                text: '${progress.achievementPercent}%',
                textSize: TextSize.L,
                color: CustomColors.thema,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clampedProgress,
              minHeight: 10,
              backgroundColor: CustomColors.thema.withAlpha(35),
              valueColor: const AlwaysStoppedAnimation<Color>(
                CustomColors.thema,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _AmountRow(
            label: AnnualTargetLabels.target,
            value: formatAmount(progress.targetAmount),
          ),
          _AmountRow(
            label: AnnualTargetLabels.actual,
            value: formatAmount(progress.actualAmount),
          ),
          _AmountRow(
            label: AnnualTargetLabels.forecast,
            value: formatAmount(progress.projectedAmount),
          ),
          _AmountRow(
            label: AnnualTargetLabels.remaining,
            value: formatAmount(progress.remainingAmount),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;

  const _AmountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, textSize: TextSize.S),
          CustomText(
            text: value,
            textSize: TextSize.MS,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
