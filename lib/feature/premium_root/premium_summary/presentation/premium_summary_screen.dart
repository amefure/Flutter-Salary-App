import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_label_view.dart';
import 'package:salary/feature/premium_root/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium_root/premium_summary/premium_summary_view_model.dart';
import 'package:salary/feature/premium_root/premium_summary/presentation/income_bar_chart.dart';

class PremiumSummaryScreen extends ConsumerWidget {
  const PremiumSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(premiumSummaryProvider);
    // 画面サイズを取得
    final screen = MediaQuery.of(context).size;

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
              )
          ),

          const SizedBox(height: 16),

          ...?summary.summaryDto?.top10.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4A90E2),
                    Color(0xFF6FB1FC),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: CupertinoListTile(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  e.user.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${e.user.profile.job} / ${e.user.profile.region} / ${e.user.profile.ageRange}',
                  style: const TextStyle(
                      color: Colors.white70),
                ),
                trailing: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(e.totalPaymentAmount / 10000).toStringAsFixed(0)}万円',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '手取り ${(e.totalNetSalary / 10000).toStringAsFixed(0)}万円',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 40),

          /// ====== 分布 ======

          SizedBox(
              width: screen.width * 0.95,
              child: const CustomLabelView(
                labelText: '年収分布',
                icon: CupertinoIcons.chart_bar_alt_fill,
                size: 25,
              )
          ),

          const SizedBox(height: 8),

          if (summary.summaryDto?.distribution != null)
            IncomeBarChart(summary.summaryDto!.distribution.withZeroFilled().reversed.toList()),
        ],
      ),
    );
  }
}
