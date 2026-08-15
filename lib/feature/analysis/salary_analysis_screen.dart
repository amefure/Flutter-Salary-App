import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'salary_analysis_state.dart';
import 'salary_analysis_view_model.dart';

class SalaryAnalysisScreen extends ConsumerStatefulWidget {
  const SalaryAnalysisScreen({super.key});

  @override
  ConsumerState<SalaryAnalysisScreen> createState() => _SalaryAnalysisScreenState();
}

class _SalaryAnalysisScreenState extends ConsumerState<SalaryAnalysisScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: '給与ディープ分析',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedSegment,
                  children: const {
                    0: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('月別比較', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('項目別累計', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  },
                  onValueChanged: (value) {
                    if (value != null) setState(() => _selectedSegment = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedSegment == 0 ? const _ComparisonView() : const _ItemSummaryView(),
            ),
            const AdMobBannerWidget(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ComparisonView extends ConsumerWidget {
  const _ComparisonView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryAnalysisProvider);
    final vm = ref.read(salaryAnalysisProvider.notifier);

    // IDを元に確実に一意のデータを取得
    final baseSalary = vm.findSalaryById(state.baseSalaryId);
    final targetSalary = vm.findSalaryById(state.targetSalaryId);

    final baseNet = baseSalary?.netSalary ?? 0;
    final targetNet = targetSalary?.netSalary ?? 0;
    final diffNet = targetNet - baseNet;

    final allKeys = <String>{
      ...?baseSalary?.paymentAmountItems.map((e) => e.key),
      ...?targetSalary?.paymentAmountItems.map((e) => e.key),
      ...?baseSalary?.deductionAmountItems.map((e) => e.key),
      ...?targetSalary?.deductionAmountItems.map((e) => e.key),
    };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          children: [
            Expanded(
              child: _datePickerCard(
                context,
                title: '基準月',
                salary: baseSalary,
                onTap: () => _showSavedMonthActionSheet(context, state, (selectedId) {
                  vm.updateBaseSalaryId(selectedId);
                }),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(CupertinoIcons.arrow_right, color: CustomColors.thema, size: 18),
            ),
            Expanded(
              child: _datePickerCard(
                context,
                title: '比較月',
                salary: targetSalary,
                onTap: () => _showSavedMonthActionSheet(context, state, (selectedId) {
                  vm.updateTargetSalaryId(selectedId);
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CustomColors.thema.withAlpha(51), width: 1), // withOpacity -> withAlpha (0.2 = 51)
            boxShadow: [
              BoxShadow(
                color: CustomColors.thema.withAlpha(13), // withOpacity -> withAlpha (0.05 = 13)
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const CustomText(text: '手取り額の増減差分', color: CupertinoColors.systemGrey, textSize: TextSize.S),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    diffNet >= 0 ? CupertinoIcons.arrow_up_right_circle_fill : CupertinoIcons.arrow_down_right_circle_fill,
                    color: diffNet >= 0 ? CupertinoColors.activeGreen : CupertinoColors.systemRed,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: '${diffNet >= 0 ? "+" : ""}${NumberUtils.formatWithComma(diffNet)} 円',
                    textSize: TextSize.L,
                    fontWeight: FontWeight.bold,
                    color: diffNet >= 0 ? CupertinoColors.activeGreen : CupertinoColors.systemRed,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: CupertinoColors.systemGrey5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _amountColumn('基準月手取り', baseNet),
                  Container(height: 30, width: 0.5, color: CupertinoColors.systemGrey5),
                  _amountColumn('比較月手取り', targetNet),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: CustomText(
            text: '詳細項目別の差分',
            fontWeight: FontWeight.bold,
            textSize: TextSize.M,
          ),
        ),
        const SizedBox(height: 12),

        if (baseSalary == null || targetSalary == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CustomText(text: '両方の給料データを選択してください', color: CupertinoColors.systemGrey),
            ),
          )
        else
          ...allKeys.map((key) {
            final baseVal = _findItemValue(baseSalary, key);
            final targetVal = _findItemValue(targetSalary, key);
            final diff = targetVal - baseVal;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: key, fontWeight: FontWeight.w600),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CustomText(text: '${NumberUtils.formatWithComma(baseVal)}円', textSize: TextSize.SS, color: CupertinoColors.systemGrey),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(CupertinoIcons.chevron_right, size: 10, color: CupertinoColors.systemGrey),
                            ),
                            CustomText(text: '${NumberUtils.formatWithComma(targetVal)}円', textSize: TextSize.SS, color: CupertinoColors.systemGrey),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: diff > 0
                          ? CupertinoColors.activeGreen.withAlpha(31) // withOpacity(0.12) -> withAlpha(31)
                          : diff < 0
                          ? CupertinoColors.systemRed.withAlpha(31)
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomText(
                      text: '${diff > 0 ? "+" : ""}${NumberUtils.formatWithComma(diff)}円',
                      fontWeight: FontWeight.bold,
                      textSize: TextSize.S,
                      color: diff > 0
                          ? CupertinoColors.activeGreen
                          : diff < 0
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  int _findItemValue(Salary? salary, String key) {
    if (salary == null) return 0;
    for (var item in [...salary.paymentAmountItems, ...salary.deductionAmountItems]) {
      if (item.key == key) return item.value;
    }
    return 0;
  }

  // コールバックに日付ではなく一意のID（salary.id）を渡すよう変更
  void _showSavedMonthActionSheet(
      BuildContext context, SalaryAnalysisState state, ValueChanged<String> onSelected) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('比較する月を選択'),
        actions: state.allSalaries.map((salary) {
          final dateStr = DateTimeUtils.format(dateTime: salary.createdAt);
          final bonusStr = salary.isBonus ? '(賞)' : '';
          final sourceStr = salary.source?.name ?? '未設定';

          return CupertinoActionSheetAction(
            onPressed: () {
              onSelected(salary.id); // 一意のIDを渡すことで同月の別データも正しく区別できる
              Navigator.of(context).pop();
            },
            child: CustomText(text: '$dateStr$bonusStr - $sourceStr'),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  Widget _datePickerCard(BuildContext context, {required String title, required Salary? salary, required VoidCallback onTap}) {
    final date = salary?.createdAt;
    final sourceStr = salary?.source?.name;
    final bonusStr = salary?.isBonus == true ? '(賞)' : '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColors.thema.withAlpha(76), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: title, textSize: TextSize.SS, color: CupertinoColors.systemGrey),
                const Icon(CupertinoIcons.chevron_down, size: 12, color: CustomColors.thema),
              ],
            ),
            const SizedBox(height: 6),
            CustomText(
              text: date != null ? '${date.year}年${date.month}月 $bonusStr ${sourceStr != null ? "\n$sourceStr" : ""}' : '未選択',
              fontWeight: FontWeight.bold,
              textSize: TextSize.S,
              color: CustomColors.thema,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountColumn(String label, int amount) {
    return Column(
      children: [
        CustomText(text: label, textSize: TextSize.SS, color: CupertinoColors.systemGrey),
        const SizedBox(height: 4),
        CustomText(text: '${NumberUtils.formatWithComma(amount)} 円', fontWeight: FontWeight.bold, textSize: TextSize.S),
      ],
    );
  }
}

class _ItemSummaryView extends ConsumerWidget {
  const _ItemSummaryView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryAnalysisProvider);
    final vm = ref.read(salaryAnalysisProvider.notifier);
    final history = vm.getFilteredItemHistory();
    final totalSum = history.values.fold(0, (sum, val) => sum + val);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.availableItemNames.length,
            itemBuilder: (context, index) {
              final itemName = state.availableItemNames[index];
              final isSelected = state.selectedItemName == itemName;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => vm.selectItemName(itemName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? CustomColors.thema : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: CupertinoColors.systemGrey5, width: 0.5),
                    ),
                    child: CustomText(
                      text: itemName,
                      color: isSelected ? CupertinoColors.white : CustomColors.text(context),
                      fontWeight: FontWeight.w600,
                      textSize: TextSize.S,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.thema.withAlpha(51), width: 1), // withOpacity -> withAlpha (51)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: '「${state.selectedItemName ?? "未選択"}」の累計',
                  textSize: TextSize.S,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(height: 6),
                CustomText(
                  text: '${NumberUtils.formatWithComma(totalSum)} 円',
                  textSize: TextSize.L,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.thema,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: history.isEmpty
              ? const Center(child: CustomText(text: '該当するデータがありません', color: CupertinoColors.systemGrey))
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: history.keys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final key = history.keys.elementAt(index);
              final value = history[key]!;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: key, fontWeight: FontWeight.w600),
                    CustomText(
                      text: '${NumberUtils.formatWithComma(value)} 円',
                      fontWeight: FontWeight.bold,
                      color: CustomColors.thema,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}