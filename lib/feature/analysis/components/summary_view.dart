import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/analysis/domain/salary_analysis_models.dart';
import 'package:salary/feature/analysis/salary_analysis_state.dart';
import 'package:salary/feature/analysis/salary_analysis_view_model.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_view.dart';

class SummaryView extends ConsumerWidget {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryAnalysisProvider);
    final vm = ref.read(salaryAnalysisProvider.notifier);
    final summary = state.summary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _FilterButton(
          selected: _filterLabel(state.selectedSourceFilter, vm),
          onPressed: () => _showFilterSheet(context, state, vm),
        ),
        const SizedBox(height: 16),
        if (summary.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: CustomText(
                text: '集計できる給料データがありません',
                color: CupertinoColors.systemGrey,
              ),
            ),
          )
        else ...[
          _MetricCard(
            title: '平均月給',
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
          const SizedBox(height: 12),
          _MetricCard(
            title: '累計額',
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
          const SizedBox(height: 20),
          _RankingSection(
            title: '総支給額 TOP 3',
            salaries: summary.grossRanking,
            amount: (salary) => salary.paymentAmount,
            vm: vm,
          ),
          const SizedBox(height: 20),
          _RankingSection(
            title: '手取り額 TOP 3',
            salaries: summary.netRanking,
            amount: (salary) => salary.netSalary,
            vm: vm,
          ),
        ],
      ],
    );
  }

  String _filterLabel(SalarySourceFilter filter, SalaryAnalysisViewModel vm) {
    switch (filter.kind) {
      case SalarySourceFilterKind.all:
        return '支払い元: すべて';
      case SalarySourceFilterKind.source:
        return '支払い元: ${vm.sourceNameForId(filter.sourceId)}';
      case SalarySourceFilterKind.unspecified:
        return '支払い元: 未設定';
    }
  }

  void _showFilterSheet(
    BuildContext context,
    SalaryAnalysisState state,
    SalaryAnalysisViewModel vm,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: const Text('支払い元で絞り込み'),
            actions:
                state.sourceFilters.map((filter) {
                  final label = switch (filter.kind) {
                    SalarySourceFilterKind.all => 'すべて',
                    SalarySourceFilterKind.source => vm.sourceNameForId(
                      filter.sourceId,
                    ),
                    SalarySourceFilterKind.unspecified => '未設定',
                  };
                  return CupertinoActionSheetAction(
                    isDefaultAction:
                        filter.kind == state.selectedSourceFilter.kind &&
                        filter.sourceId == state.selectedSourceFilter.sourceId,
                    onPressed: () {
                      vm.selectSourceFilter(filter);
                      Navigator.of(context).pop();
                    },
                    child: Text(label),
                  );
                }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
          ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String selected;
  final VoidCallback onPressed;

  const _FilterButton({required this.selected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: CustomColors.background(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.line_horizontal_3_decrease, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: CustomText(
                text: selected,
                fontWeight: FontWeight.bold,
                color: CustomColors.text(context),
              ),
            ),
            const Icon(CupertinoIcons.chevron_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _MetricCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: children[0]),
              Container(
                height: 40,
                width: 1,
                color: CupertinoColors.systemGrey5,
              ),
              Expanded(child: children[1]),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricValue({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          text: label,
          textSize: TextSize.S,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(height: 4),
        CustomText(
          text: '${NumberUtils.formatWithComma(value)} 円',
          textSize: TextSize.M,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ],
    );
  }
}

class _RankingSection extends StatelessWidget {
  final String title;
  final List<Salary> salaries;
  final int Function(Salary) amount;
  final SalaryAnalysisViewModel vm;

  const _RankingSection({
    required this.title,
    required this.salaries,
    required this.amount,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: title, fontWeight: FontWeight.bold),
        const SizedBox(height: 8),
        ...salaries.asMap().entries.map(
          (entry) => _RankingCard(
            rank: entry.key + 1,
            salary: entry.value,
            amount: amount(entry.value),
            sourceName: vm.sourceNameForId(entry.value.source?.id),
            onTap:
                () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder:
                        (_) => DetailSalaryView(
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
  final int rank;
  final Salary salary;
  final int amount;
  final String sourceName;
  final VoidCallback onTap;

  const _RankingCard({
    required this.rank,
    required this.salary,
    required this.amount,
    required this.sourceName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomColors.background(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CustomText(
                text: '$rank',
                textSize: TextSize.L,
                fontWeight: FontWeight.bold,
                color: CustomColors.thema,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text:
                          '${DateTimeUtils.format(dateTime: salary.createdAt)}${salary.isBonus ? ' (賞与)' : ''}',
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 3),
                    CustomText(
                      text: sourceName,
                      textSize: TextSize.S,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
              CustomText(
                text: '${NumberUtils.formatWithComma(amount)} 円',
                fontWeight: FontWeight.bold,
                color: CustomColors.text(context),
              ),
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.chevron_right, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
