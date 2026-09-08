import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/domain/payment_icon_view.dart';
import 'package:salary/core/common/components/domain/payment_source_label_view.dart';
import 'package:salary/core/models/dummy_source.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/charts/presentation/chart_salary_screen.dart'; // SourceSelector が定義されている場所
import 'package:salary/feature/salary/detail_salary/detail_salary_view.dart';
import 'package:salary/feature/analysis/salary_analysis_view_model.dart';

class SummaryView extends ConsumerWidget {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面サイズを取得
    final screen = MediaQuery.of(context).size;
    final state = ref.watch(salaryAnalysisProvider);
    final vm = ref.read(salaryAnalysisProvider.notifier);
    final summary = state.summary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [

        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: screen.width * 0.5,
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
          const SizedBox(height: 24),
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
            icon: CupertinoIcons.money_yen,
            salaries: summary.netRanking,
            amount: (salary) => salary.netSalary,
            vm: vm,
          ),
        ],
      ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, fontWeight: FontWeight.bold, textSize: TextSize.MS),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: children[0]),
              Container(
                height: 32,
                width: 1,
                color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
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
          textSize: TextSize.SS,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: CustomText(
            text: '${NumberUtils.formatWithComma(value)} 円',
            textSize: TextSize.ML,
            fontWeight: FontWeight.bold,
            color: color,
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
    Color medalColor;
    switch (index) {
      case 0:
        medalColor = const Color(0xFFD4AF37); // 金
        break;
      case 1:
        medalColor = const Color(0xFFC0C0C0); // 銀
        break;
      case 2:
      default:
        medalColor = const Color(0xFFCD7F32); // 銅
        break;
    }

    final rank = index + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CustomColors.background(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  boxShadow: index < 3 ? [
                    BoxShadow(
                        color: medalColor.withAlpha(30),
                        blurRadius: 4,
                        offset: const Offset(0, 2)
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text:
                      '${DateTimeUtils.format(dateTime: salary.createdAt)}${salary.isBonus ? ' (賞与)' : ''}',
                      fontWeight: FontWeight.bold,
                      textSize: TextSize.MS,
                    ),
                    const SizedBox(height: 2),
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
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.systemGrey),
            ],
          ),
        ),
      ),
    );
  }
}