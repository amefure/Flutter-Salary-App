import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/domain/payment_icon_view.dart';
import 'package:salary/core/common/components/domain/payment_source_label_view.dart';
import 'package:salary/core/common/components/domain/source_selector.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/charts/presentation/parts/empty_chart_view.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_view.dart';
import 'package:salary/feature/analysis/salary_analysis_view_model.dart';

class SummaryView extends ConsumerWidget {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryAnalysisProvider);
    final vm = ref.read(salaryAnalysisProvider.notifier);
    final summary = state.summary;

    final double netRate = summary.grossTotal == 0
        ? 0.0
        : (summary.netTotal / summary.grossTotal) * 100;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Align(
          alignment: Alignment.center,
          child: SourceSelector(
            selectedSource: state.selectedSource,
            sourceList: state.sourceList,
            sourceName: (source) => source?.name ?? '未設定',
            buildLabelView: (source) => PaymentSourceLabelView(
              paymentSource: source,
              isShowChevronDown: true,
            ),
            buildIconView: (source) => PaymentIconView(paymentSource: source),
            onChanged: (source) {
              if (source != null) {
                vm.selectSource(source);
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        if (summary.isEmpty)
          const EmptyChartView()
        else ...[
          // 平均月給
          _MetricCard(
            title: '平均月給',
            icon: CupertinoIcons.calendar,
            children: [
              _MetricValue(
                label: '総支給',
                value: summary.averageMonthlyGross.round(),
                color: CustomColors.thema,
              ),
              _MetricValue(
                label: '手取り',
                value: summary.averageMonthlyNet.round(),
                color: CustomColors.themaBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 平均年収
          _MetricCard(
            title: '平均年収',
            icon: CupertinoIcons.money_dollar_circle,
            children: [
              _MetricValue(
                label: '総支給',
                value: summary.averageYearlyGross.round(),
                color: CustomColors.thema,
              ),
              _MetricValue(
                label: '手取り',
                value: summary.averageYearlyNet.round(),
                color: CustomColors.themaBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 手取り率＆控除額
          _ProgressMetricCard(
            title: '手取り率・控除分析',
            percentage: netRate,
            icon: CupertinoIcons.percent,
            children: [
              _MetricValue(
                label: '累計控除額',
                value: summary.grossTotal - summary.netTotal,
                color: CupertinoColors.systemRed,
              ),
              _MetricValue(
                label: '平均手取り率',
                value: netRate,
                color: CustomColors.themaBlue,
                unit: _MetricUnit.percent,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 賞与累計額
          _ProgressMetricCard(
            title: '賞与実績',
            percentage: summary.bonusRatio,
            icon: CupertinoIcons.gift,
            children: [
              _MetricValue(
                label: '累計賞与額',
                value: summary.bonusTotal,
                color: CustomColors.thema,
              ),
              _MetricValue(
                label: '年収に対する比率',
                value: summary.bonusRatio,
                color: CustomColors.themaBlue,
                unit: _MetricUnit.percent,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 総累計額
          _MetricCard(
            title: '総累計額 (${summary.yearCount}年分)',
            icon: CupertinoIcons.chart_bar_alt_fill,
            children: [
              _MetricValue(
                label: '総支給',
                value: summary.grossTotal,
                color: CustomColors.thema,
              ),
              _MetricValue(
                label: '手取り',
                value: summary.netTotal,
                color: CustomColors.themaBlue,
              ),
            ],
          ),
          const SizedBox(height: 28),

          _RankingSection(
            title: '総支給額 TOP 3',
            icon: CupertinoIcons.rosette,
            salaries: summary.grossRanking,
            amount: (salary) => salary.paymentAmount,
            vm: vm,
          ),
          const SizedBox(height: 24),
          _RankingSection(
            title: '手取り額 TOP 3',
            icon: CupertinoIcons.rosette,
            salaries: summary.netRanking,
            amount: (salary) => salary.netSalary,
            vm: vm,
          ),
        ],
      ],
    );
  }
}

/// 標準的なメトリクスカード（アイコン付き・洗練されたボーダー）
class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CustomColors.thema.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: CustomColors.thema),
              ),
              const SizedBox(width: 8),
              CustomText(text: title, fontWeight: FontWeight.bold, textSize: TextSize.MS),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: children[0]),
              Container(
                height: 36,
                width: 1,
                color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
              ),
              Expanded(child: children[1]),
            ],
          ),
        ],
      ),
    );
  }
}

/// 手取り率用のプログレスバー付きモダンカード
class _ProgressMetricCard extends StatelessWidget {
  final String title;
  final double percentage;
  final IconData icon;
  final List<Widget> children;

  const _ProgressMetricCard({
    required this.title,
    required this.percentage,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CustomColors.thema.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: CustomColors.thema),
              ),
              const SizedBox(width: 8),
              CustomText(text: title, fontWeight: FontWeight.bold, textSize: TextSize.MS),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: CupertinoColors.systemGrey.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(CustomColors.thema),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: children[0]),
              Container(
                height: 36,
                width: 1,
                color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
              ),
              Expanded(child: children[1]),
            ],
          ),
        ],
      ),
    );
  }
}

enum _MetricUnit {
  yen('円'),
  percent('%');

  final String symbol;
  const _MetricUnit(this.symbol);
}

class _MetricValue extends StatelessWidget {
  final String label;
  final num value;
  final Color color;
  final _MetricUnit unit;

  const _MetricValue({
    required this.label,
    required this.value,
    required this.color,
    this.unit = _MetricUnit.yen,
  });

  @override
  Widget build(BuildContext context) {
    final formattedValue = unit == _MetricUnit.percent
        ? value.toStringAsFixed(1)
        : NumberUtils.formatWithComma(value.toInt());

    return Column(
      children: [
        CustomText(
          text: label,
          textSize: TextSize.SS,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              CustomText(
                text: formattedValue,
                textSize: TextSize.L,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              const SizedBox(width: 2),
              CustomText(
                text: unit.symbol,
                textSize: TextSize.S,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankingSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Salary> salaries;
  final int Function(Salary) amount;
  final SalaryAnalysisViewModel vm;

  const _RankingSection({
    required this.title,
    required this.icon,
    required this.salaries,
    required this.amount,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabelView(labelText: title, icon: icon),
        const SizedBox(height: 10),
        ...salaries.asMap().entries.map(
              (entry) => _RankingCard(
            index: entry.key,
            salary: entry.value,
            amount: amount(entry.value),
            sourceName: vm.sourceNameForId(entry.value.source?.id),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => DetailSalaryView(
                  id: entry.value.id,
                  isPublic: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int index;
  final Salary salary;
  final int amount;
  final String sourceName;
  final VoidCallback onTap;

  const _RankingCard({
    required this.index,
    required this.salary,
    required this.amount,
    required this.sourceName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final medalColor = CustomColors.medalColor(context, index);
    final rank = index + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CustomColors.background(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  boxShadow: index < 3 ? [
                    BoxShadow(
                      color: medalColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ] : null,
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: '$rank',
                  textSize: TextSize.S,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: '${DateTimeUtils.format(dateTime: salary.createdAt)}${salary.isBonus ? ' (賞与)' : ''}',
                      fontWeight: FontWeight.bold,
                      textSize: TextSize.MS,
                    ),
                    const SizedBox(height: 3),
                    CustomText(
                      text: sourceName,
                      textSize: TextSize.SS,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
              CustomText(
                text: '${NumberUtils.formatWithComma(amount)} 円',
                fontWeight: FontWeight.bold,
                textSize: TextSize.MS,
                color: CustomColors.text(context),
              ),
              const SizedBox(width: 10),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: CupertinoColors.systemGrey.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}