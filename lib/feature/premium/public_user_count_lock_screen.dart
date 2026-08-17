import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/header_visual_view.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/public_salary/public_salary_screen.dart';

class PublicUserCountLockScreen extends StatelessWidget {

  const PublicUserCountLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [

          const HeaderVisualView(
            icon: CupertinoIcons.rocket_fill,
            title: '公開ありがとうございます！',
            msg: '一定の公開ユーザー数に達すると、\n統計データがアンロックされます。\nこの画面が自動で切り替わるまでしばらくお待ちください。',
          ),

          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              final premiumState = ref.watch(premiumFunctionStateProvider);
              return _ReleaseProgressCard(
                currentCount: premiumState.publicUserCount,
              );
            },
          ),

          const SizedBox(height: 12),

          /// 解放される機能のプレビュー
          const _FeaturePreviewList(),

          const SizedBox(height: 32),

          /// アクションボタン
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            color: CustomColors.themaBlue,
            borderRadius: BorderRadius.circular(30),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const PublicSalaryScreen(),
                ),
              );
            },
            child: const CustomText(
              text: 'さらにデータを公開する',
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}



/// 解放される機能のプレビュー
class _FeaturePreviewList extends StatelessWidget {
  const _FeaturePreviewList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: CustomText(
            text: '解放される機能',
            textSize: TextSize.M,
            fontWeight: FontWeight.bold,
          ),
        ),
        _LockedFeatureTile(
          icon: CupertinoIcons.graph_square_fill,
          title: '業種別・年収偏差値',
          description: 'あなたの給料が全体でどの位置か精密に分析',
        ),
        SizedBox(height: 12),
        _LockedFeatureTile(
          icon: CupertinoIcons.text_alignleft,
          title: '同年代の平均推移グラフ',
          description: '将来のキャリアパスと昇給額をシミュレーション',
        ),
      ],
    );
  }
}

class _LockedFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _LockedFeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.background(context).withAlpha(150),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey6),
      ),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.systemGrey4, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: title, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey),
                CustomText(text: description, textSize: TextSize.SS, color: CupertinoColors.systemGrey2),
              ],
            ),
          ),
          const Icon(CupertinoIcons.lock_fill, size: 16, color: CupertinoColors.systemGrey4),
        ],
      ),
    );
  }
}

class _ReleaseProgressCard extends StatelessWidget {
  final int currentCount;
  final int targetCount;
  final String title;
  final String messageTemplate;

  const _ReleaseProgressCard({
    super.key,
    required this.currentCount,
    this.targetCount = 10,
    this.title = '機能の解放まで',
    this.messageTemplate = '人の給料公開で、\nみんなの給料データが閲覧可能になります！',
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (targetCount - currentCount).clamp(0, targetCount);
    final progress = (currentCount / targetCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColors.themaOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.lock_open_fill,
                size: 18,
                color: CustomColors.themaOrange,
              ),
              const SizedBox(width: 8),
              CustomText(
                text: title,
                textSize: TextSize.S,
                fontWeight: FontWeight.bold,
              ),
              const Spacer(),
              CustomText(
                text: '$currentCount / $targetCount人',
                textSize: TextSize.S,
                color: CustomColors.themaOrange,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // プログレスバー
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: CupertinoColors.systemGrey5,
              valueColor: const AlwaysStoppedAnimation<Color>(
                CustomColors.themaOrange,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 残り人数の強調メッセージ
          CustomText(
            text: 'あと $remaining $messageTemplate',
            textSize: TextSize.SS,
            color: CupertinoColors.label,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}