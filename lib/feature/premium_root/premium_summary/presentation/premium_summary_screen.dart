import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/empty_state_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium_root/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium_root/data/dto/ranking_dto.dart';
import 'package:salary/feature/premium_root/premium_summary/premium_summary_view_model.dart';
import 'package:salary/feature/premium_root/premium_summary/presentation/income_bar_chart.dart';

class PremiumSummaryScreen extends ConsumerWidget {
  const PremiumSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(premiumSummaryProvider);
    final screen = MediaQuery.of(context).size;

    // データが存在するかどうかの判定
    final hasRanking = summary.summaryDto?.top10.isNotEmpty ?? false;
    final hasDistribution = summary.summaryDto?.distribution.isNotEmpty ?? false;

    return SingleChildScrollView(
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
            ...summary.summaryDto!.top10.asMap().entries.map((entry) {
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
            IncomeBarChart(summary.summaryDto!.distribution
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
                      _buildAttributeTag(context, profile.region, CustomColors.themaBlue),
                      const SizedBox(width: 6),
                      _buildAttributeTag(context, profile.ageRange, CustomColors.themaGreen),
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

  // 属性タグ用ヘルパー
  Widget _buildAttributeTag(BuildContext context, String text, Color baseColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomText(
        text: text,
        textSize: TextSize.SSS,
        color: baseColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

