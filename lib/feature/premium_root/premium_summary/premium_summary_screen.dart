import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/feature/premium_root/premium_summary/premium_summary_view_model.dart';

class PremiumSummaryScreen extends ConsumerWidget {
  const PremiumSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dto = ref.watch(premiumSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('プレミアムサマリー')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 年収ランキング TOP10',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...?dto.summaryDto?.top10.map((e) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(e.userId.toString()),
                ),
                title: Text(e.user.name),
                subtitle: Text(
                  '${e.user.profile.job} / ${e.user.profile.region} / ${e.user.profile.ageRange}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(e.totalPaymentAmount / 10000).toStringAsFixed(0)}万円',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '手取り ${(e.totalNetSalary / 10000).toStringAsFixed(0)}万円',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 32),

            const Text(
              '📊 年収分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...?dto.summaryDto?.distribution.map((e) => Card(
              child: ListTile(
                title: Text('${e.incomeRange}万円'),
                trailing: Text('${e.userCount}人'),
              ),
            )),
          ],
        ),
      )
    );
  }
}