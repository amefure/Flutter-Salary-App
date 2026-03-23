import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom_action_picker.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/custom_filter_chip.dart';
import 'package:salary/core/common/components/domain/attribute_tag.dart';
import 'package:salary/core/common/components/empty_state_view.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/presentation/components/job_picker_modal.dart';
import 'package:salary/feature/premium/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium/data/dto/ranking_dto.dart';
import 'package:salary/feature/premium/premium_summary/premium_summary_state.dart';
import 'package:salary/feature/premium/premium_summary/premium_summary_view_model.dart';
import 'package:salary/feature/premium/premium_summary/presentation/income_bar_chart.dart';

class PremiumSummaryScreen extends ConsumerWidget {
  const PremiumSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumSummaryProvider);
    final viewModel = ref.read(premiumSummaryProvider.notifier);
    final screen = MediaQuery.of(context).size;

    // データが存在するかどうかの判定
    final hasRanking = state.summaryDto?.top10.isNotEmpty ?? false;
    final hasDistribution = state.summaryDto?.distribution.isNotEmpty ?? false;

    return Column(
      children: [

        /// ====== フィルターエリア ======
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 12),
              CustomFilterChip(
                label: '${state.selectedYear}年',
                onTap: () {
                  final premiumState = ref.read(premiumFunctionStateProvider);
                  if (premiumState.isPremiumFeatureUnlocked) {
                    _showYearPicker(context, viewModel, state);
                  } else {
                    _showIsNotPremiumErrorAlert(context);
                  }
                },
              ),
              CustomFilterChip(
                label: !state.isUndefinedJob ? state.selectedJob.name : 'すべての職種',
                onTap: () {
                  final premiumState = ref.read(premiumFunctionStateProvider);
                  if (premiumState.isPremiumFeatureUnlocked) {
                    _showJobPicker(context, viewModel, state);
                  } else {
                    _showIsNotPremiumErrorAlert(context);
                  }
                },
              ),
              CustomFilterChip(
                label: state.selectedRegion ?? 'すべての地域',
                onTap: () {
                  final premiumState = ref.read(premiumFunctionStateProvider);
                  if (premiumState.isPremiumFeatureUnlocked) {
                    _showRegionPicker(context, viewModel, state);
                  } else {
                    _showIsNotPremiumErrorAlert(context);
                  }
                },
              ),
              CustomFilterChip(
                label: state.selectedAgeRange ?? 'すべての年代',
                onTap: () {
                  final premiumState = ref.read(premiumFunctionStateProvider);
                  if (premiumState.isPremiumFeatureUnlocked) {
                    _showAgePicker(context, viewModel, state);
                  } else {
                    _showIsNotPremiumErrorAlert(context);
                  }
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ====== ランキング ======
              SizedBox(
                  width: screen.width * 0.95,
                  child: const CustomLabelView(
                    labelText: '年収ランキング TOP10',
                    icon: CupertinoIcons.profile_circled,
                    size: 25,
                  )),

              const SizedBox(height: 16),

              if (hasRanking)
                ...state.summaryDto!.top10.asMap().entries.map((entry) {
                  return _RankingItem(
                    index: entry.key,
                    ranking: entry.value,
                  );
                })
              else
                const EmptyStateView(
                  message: 'ランキングデータがまだありません',
                  icon: CupertinoIcons.person_badge_minus,
                ),

              const SizedBox(height: 40),

              /// ====== 分布 ======
              SizedBox(
                  width: screen.width * 0.95,
                  child: const CustomLabelView(
                    labelText: '年収分布',
                    icon: CupertinoIcons.chart_bar_alt_fill,
                    size: 25,
                  )),

              const SizedBox(height: 8),

              if (hasDistribution)
                IncomeBarChart(state.summaryDto!.distribution
                    .withZeroFilled()
                    .reversed
                    .toList())
              else
                const EmptyStateView(
                  message: '分布データが集計されていません',
                  icon: CupertinoIcons.chart_pie,
                ),

            ],
          ),
        ))
      ],
    );
  }

  void _showIsNotPremiumErrorAlert(BuildContext context) {
    final _ = AppDialog.show(
      context: context,
      message: 'この機能を使用するにはプレミアム機能を解放してください。\n設定から解放することが可能です。',
      type: DialogType.notify,
    );
  }

  /// 職種選択ピッカーを表示
  void _showJobPicker(BuildContext context, PremiumSummaryViewModel notifier, PremiumSummaryState state) async {
    final selected = await showModalBottomSheet<Job>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobPickerModal(
        currentJob: state.selectedJob,
        showNoneOption: true,
      ),
    );
    if (selected != null) {
      notifier.updateFilter(job: selected);
    }
  }

  /// 年選択ピッカー
  void _showYearPicker(BuildContext context, PremiumSummaryViewModel notifier, PremiumSummaryState state) {

    CustomActionPicker.show<String>(
      context: context,
      title: '対象年を選択',
      items: PremiumSummaryViewModel.years.map((y) => y.toString()).toList(),
      // 現在の状態（state）から選択中の値を渡す
      currentValue: state.selectedYear.toString(),
      // リストの各要素をどう表示するか（今回はStringなのでそのまま）
      labelBuilder: (item) => item,
      onSelected: (selected) {
    notifier.updateFilter(year: int.parse(selected));
      },
    );
  }

  /// 地域選択ピッカー
  void _showRegionPicker(BuildContext context, PremiumSummaryViewModel notifier, PremiumSummaryState state) {
    CustomActionPicker.show<String>(
      context: context,
      title: '地域を選択',
      items: [ProfileConfig.selectNone, ...ProfileConfig.prefectures],
      currentValue: state.selectedRegion ?? ProfileConfig.selectNone,
      labelBuilder: (item) => item,
      onSelected: (selected) {
        notifier.updateFilter(region: selected);
      },
    );
  }
  /// 年代選択ピッカー
  void _showAgePicker(BuildContext context, PremiumSummaryViewModel notifier, PremiumSummaryState state) {

    CustomActionPicker.show<String>(
      context: context,
      title: '年代を選択',
      items: ProfileConfig.ages,
      currentValue: state.selectedAgeRange ?? ProfileConfig.selectNone,
      labelBuilder: (item) => item,
      onSelected: (selected) {
        notifier.updateFilter(ageRange: selected);
      },
    );
  }
}

class _RankingItem extends StatelessWidget {
  final int index;
  final RankingDto ranking;

  const _RankingItem({
    required this.index,
    required this.ranking,
  });

  @override
  Widget build(BuildContext context) {
    final profile = ranking.user.profile;

    // 1, 2, 3位のメダルカラー判定
    Color medalColor;
    switch (index) {
      case 0: medalColor = const Color(0xFFD4AF37); break; // 金
      case 1: medalColor = const Color(0xFFC0C0C0); break; // 銀
      case 2: medalColor = const Color(0xFFCD7F32); break; // 銅
      default: medalColor = CustomColors.foundation(context);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(12),
        // 上位3位のみ薄いボーダーをつける
        border: index < 3
            ? Border.all(color: medalColor.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 順位表示
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: medalColor,
                shape: BoxShape.circle,
                boxShadow: index < 3 ? [
                  BoxShadow(
                      color: medalColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2)
                  )
                ] : null,
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: '${index + 1}',
                textSize: TextSize.S,
                fontWeight: FontWeight.bold,
                color: index < 3 ? Colors.white : CustomColors.text(context),
              ),
            ),
            const SizedBox(width: 14),

            // メイン情報 (職種と属性タグ)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: profile.job,
                    textSize: TextSize.MS,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      AttributeTag(text: profile.region, baseColor: CustomColors.themaBlue),
                      const SizedBox(width: 6),
                      AttributeTag(text: profile.ageRange, baseColor: CustomColors.themaGreen),
                    ],
                  ),
                ],
              ),
            ),

            // 金額情報
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: '${(ranking.totalPaymentAmount / 10000).toStringAsFixed(0)}万円',
                  textSize: TextSize.M,
                  fontWeight: FontWeight.bold,
                  color: index == 0 ? medalColor : CustomColors.themaBlue,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: '手取り ${(ranking.totalNetSalary / 10000).toStringAsFixed(0)}万',
                  textSize: TextSize.SSS,
                  color: CustomColors.themaGray,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

