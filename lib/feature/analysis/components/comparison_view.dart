import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/number_utils.dart';
import '../salary_analysis_state.dart';
import '../salary_analysis_view_model.dart';

class ComparisonView extends ConsumerWidget {
  const ComparisonView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryAnalysisProvider);
    final vm = ref.read(salaryAnalysisProvider.notifier);

    // IDを元に確実に一意のデータを取得
    final baseSalary = vm.findSalaryById(state.baseSalaryId);
    final targetSalary = vm.findSalaryById(state.targetSalaryId);

    // 手取り
    final baseNet = baseSalary?.netSalary ?? 0;
    final targetNet = targetSalary?.netSalary ?? 0;
    final diffNet = targetNet - baseNet;

    // 総支給
    final baseGross = baseSalary?.paymentAmount ?? 0;
    final targetGross = targetSalary?.paymentAmount ?? 0;
    final diffGross = targetGross - baseGross;

    // 控除額（総支給 - 手取り または 控除項目の合計など）
    final baseDeduction = baseSalary?.deductionAmount ?? 0;
    final targetDeduction = targetSalary?.deductionAmount ?? 0;
    final diffDeduction = targetDeduction - baseDeduction;

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

        // ==================== 総支給額の増減差分カード ====================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CustomColors.thema.withAlpha(51), width: 1),
            boxShadow: [
              BoxShadow(
                color: CustomColors.thema.withAlpha(13),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const CustomText(text: '総支給額の増減差分', color: CupertinoColors.systemGrey, textSize: TextSize.S),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    diffGross >= 0 ? CupertinoIcons.arrow_up_right_circle_fill : CupertinoIcons.arrow_down_right_circle_fill,
                    color: diffGross >= 0 ? CupertinoColors.activeGreen : CustomColors.negative,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: '${diffGross >= 0 ? "+" : ""}${NumberUtils.formatWithComma(diffGross)} 円',
                    textSize: TextSize.L,
                    fontWeight: FontWeight.bold,
                    color: diffGross >= 0 ? CupertinoColors.activeGreen : CustomColors.negative,
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
                  _amountColumn('基準月総支給', baseGross),
                  Container(height: 30, width: 0.5, color: CupertinoColors.systemGrey5),
                  _amountColumn('比較月総支給', targetGross),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ==================== 控除額の増減差分カード ====================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CustomColors.thema.withAlpha(51), width: 1),
            boxShadow: [
              BoxShadow(
                color: CustomColors.thema.withAlpha(13),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const CustomText(text: '控除額の増減差分', color: CupertinoColors.systemGrey, textSize: TextSize.S),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 控除は増えるとマイナス（手取りが減る）なので、色やアイコンの解釈を反転させるかお好みで調整可能
                  // ここでは「控除が増えたら赤（マイナス）、減ったら緑（プラス）」で表現
                  Icon(
                    diffDeduction <= 0 ? CupertinoIcons.arrow_down_right_circle_fill : CupertinoIcons.arrow_up_right_circle_fill,
                    color: diffDeduction <= 0 ? CupertinoColors.activeGreen : CustomColors.negative,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: '${diffDeduction >= 0 ? "+" : ""}${NumberUtils.formatWithComma(diffDeduction)} 円',
                    textSize: TextSize.L,
                    fontWeight: FontWeight.bold,
                    color: diffDeduction <= 0 ? CupertinoColors.activeGreen : CustomColors.negative,
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
                  _amountColumn('基準月控除', baseDeduction),
                  Container(height: 30, width: 0.5, color: CupertinoColors.systemGrey5),
                  _amountColumn('比較月控除', targetDeduction),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ==================== 手取り額の増減差分カード ====================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CustomColors.thema.withAlpha(51), width: 1),
            boxShadow: [
              BoxShadow(
                color: CustomColors.thema.withAlpha(13),
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
                    color: diffNet >= 0 ? CupertinoColors.activeGreen : CustomColors.negative,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: '${diffNet >= 0 ? "+" : ""}${NumberUtils.formatWithComma(diffNet)} 円',
                    textSize: TextSize.L,
                    fontWeight: FontWeight.bold,
                    color: diffNet >= 0 ? CupertinoColors.activeGreen : CustomColors.negative,
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
            final isDeduction = _isDeductionItem(baseSalary, targetSalary, key);

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
                        Row(
                          children: [
                            // 支給(青) / 控除(赤) のラベルバッジ
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDeduction
                                    ? CustomColors.negative.withAlpha(26)
                                    : CustomColors.thema.withAlpha(26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: CustomText(
                                text: isDeduction ? '控除' : '支給',
                                textSize: TextSize.SS,
                                color: isDeduction ? CustomColors.negative : CustomColors.thema,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomText(text: key, fontWeight: FontWeight.w600, maxLines: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                          ? CupertinoColors.activeGreen.withAlpha(31)
                          : diff < 0
                          ? CustomColors.negative.withAlpha(31)
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
                          ? CustomColors.negative
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

  // 項目が控除項目かどうかを判定するヘルパー
  bool _isDeductionItem(Salary? base, Salary? target, String key) {
    final inBaseDeduction = base?.deductionAmountItems.any((e) => e.key == key) ?? false;
    final inTargetDeduction = target?.deductionAmountItems.any((e) => e.key == key) ?? false;
    return inBaseDeduction || inTargetDeduction;
  }

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
              onSelected(salary.id);
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