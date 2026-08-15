import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/number_utils.dart';
import '../salary_analysis_view_model.dart';

class ItemSummaryView extends ConsumerWidget {
  const ItemSummaryView({super.key});

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