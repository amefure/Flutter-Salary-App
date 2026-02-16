

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/auth/auth_state.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';

class TimeLineRootScreen extends StatelessWidget {

  const TimeLineRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: 'タイムライン',
            fontWeight: FontWeight.bold,
          )
      ),
      child: SafeArea(
        child: Consumer(
            builder: (context, ref, _) {
              final isLogin = ref.watch(authControllerProvider).isLogin;
              return TimelineLockScreen();
            }
        ),
      ),
    );
  }
}
class TimelineLockScreen extends ConsumerWidget {
  const TimelineLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          /// 🔒 上部アイコン
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColors.themaOrange.withOpacity(0.1),
            ),
            child: const Icon(
              CupertinoIcons.lock_fill,
              size: 32,
              color: CustomColors.themaOrange,
            ),
          ),

          const SizedBox(height: 8),

          /// 💎 プレミアム説明カード
          _PremiumCard(),

          const SizedBox(height: 24),

          /// ✅ 条件カード
          _RequirementCard(authState: authState),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.foundation(context),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 8),

          CustomText(
            text: 'あなたの市場価値を、データで見える化。',
            textSize: TextSize.M,
            fontWeight: FontWeight.w600,
          ),

          SizedBox(height: 8),

          CustomText(
            text:
            '同年代・同業種のリアルな給料データから\n'
                '今の立ち位置を比較してみよう。',
            textSize: TextSize.S,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
            maxLines: 2,
          ),

          SizedBox(height: 12),

          _PremiumPoint(
            icon: CupertinoIcons.money_yen_circle_fill,
            title: '月々のリアル給料を閲覧',
            description: 'みんなの実際の月収データをチェック',
          ),

          SizedBox(height: 12),

          _PremiumPoint(
            icon: CupertinoIcons.chart_bar_alt_fill,
            title: '同年代の年収ランキング',
            description: '自分のポジションが一目で分かる',
          ),

          SizedBox(height: 12),

          _PremiumPoint(
            icon: CupertinoIcons.gift_fill,
            title: 'ボーナス相場を確認',
            description: '業界ごとの支給実績を比較',
          ),
        ],
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  const _RequirementCard({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.foundation(context),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const CustomText(
            text: '利用条件',
            textSize: TextSize.M,
            fontWeight: FontWeight.bold,
          ),

          const SizedBox(height: 8),

          const CustomText(
            text: '以下の条件を満たすことで機能が解放されます。',
            textSize: TextSize.S,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
            maxLines: 2,
          ),

          const SizedBox(height: 12),

          _StepItem(
            number: 1,
            title: 'アカウント作成(ログイン)',
            isCompleted: authState.isLogin,
          ),

          _StepItem(
            number: 2,
            title: '給料データを公開',
            isCompleted: false,
          ),

          _StepItem(
            number: 3,
            title: 'プレミアム登録',
            isCompleted: authState.isLogin,
          ),

        ],
      ),
    );
  }
}

class _PremiumPoint extends StatelessWidget {
  const _PremiumPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: CustomColors.themaBlue.withOpacity(0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// アイコン背景付き
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomColors.themaBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: CustomColors.themaBlue,
            ),
          ),

          const SizedBox(width: 12),

          /// テキスト
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  textSize: TextSize.M,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: description,
                  textSize: TextSize.S,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.isCompleted,
  });

  final int number;
  final String title;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isCompleted
            ? CustomColors.themaBlue.withOpacity(0.08)
            : CustomColors.foundation(context),
      ),
      child: Row(
        children: [

          /// 丸アイコン
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? CustomColors.themaBlue
                  : CustomColors.themaBlack,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                CupertinoIcons.check_mark,
                size: 16,
                color: CupertinoColors.white,
              )
                  : CustomText(
                text: number.toString(),
                textSize: TextSize.S,
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// タイトル
          Expanded(
            child: CustomText(
              text: title,
              textSize: TextSize.M,
              fontWeight:
              isCompleted ? FontWeight.w600 : FontWeight.normal,
              color: CustomColors.text(context),
            ),
          ),

          /// 完了ラベル
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: CustomColors.themaBlue.withOpacity(0.15),
              ),
              child: const CustomText(
                text: '完了',
                textSize: TextSize.S,
                fontWeight: FontWeight.w600,
                color: CustomColors.themaBlue,
              ),
            ),
        ],
      ),
    );
  }
}
