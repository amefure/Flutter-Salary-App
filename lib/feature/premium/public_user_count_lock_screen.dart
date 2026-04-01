import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/header_visual_view.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium/premium_lock_screen.dart';
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
              return ReleaseProgressCard(
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