import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/domain/step_item.dart';
import 'package:salary/core/common/components/header_visual_view.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/presentation/login_screen.dart';
import 'package:salary/feature/in_app_purchase/in_app_purchase_screen.dart';
import 'package:salary/feature/public_salary/public_salary_screen.dart';

class PremiumLockScreen extends StatelessWidget {
  const PremiumLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [

          /// 🔒アイコン
          HeaderVisualView(icon: CupertinoIcons.lock_fill),

          SizedBox(height: 8),

          /// プレミアム機能説明カード
          PremiumCard(),

          SizedBox(height: 24),

          /// 必須条件カード
          _RequirementCard()
        ],
      ),
    );
  }
}


/// プレミアム機能説明カード
class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.background(context),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withAlpha(30),
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

/// 必須条件カード
class _RequirementCard extends ConsumerWidget {
  const _RequirementCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final premiumState = ref.watch(premiumFunctionStateProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.background(context),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withAlpha(30),
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
            text: 'アカウントを作成し、いずれかの条件を満たすと解放されます。',
            textSize: TextSize.S,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // --- ステップ1: 必須項目 ---
          StepItem(
            number: 1,
            title: '【必須】アカウント作成 / ログイン',
            isCompleted: authState.isLogin,
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          // --- ステップ2 & 3: 選択項目 (ORグループ) ---
          Container(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CupertinoColors.systemGrey4, width: 0.5),
            ),
            child: Column(
              children: [
                StepItem(
                  number: 2,
                  title: '給料データを公開',
                  isCompleted: premiumState.isPublicData,
                  onTap: () async {
                    if (!authState.isLogin) {
                      await AppDialog.show(
                        context: context,
                        message: '給料データを公開するには\n新規登録またはログインしてください。',
                        type: DialogType.error,
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => const PublicSalaryScreen()),
                    );
                  },
                ),

                // OR の区切り
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: CustomText(
                          text: 'または',
                          textSize: TextSize.SSS,
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

                StepItem(
                  number: 3,
                  title: 'プレミアム登録',
                  isCompleted: premiumState.isPremiumUnlocked,
                  isEnabled: premiumState.isUnLimitedInAppPurchase,
                  onTap: () async {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => const InAppPurchaseScreen()),
                    );
                  },
                ),
              ],
            ),
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
        color: CustomColors.themaBlue.withAlpha(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// アイコン背景付き
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomColors.themaBlue.withAlpha(25),
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
                  textSize: TextSize.S,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: description,
                  textSize: TextSize.SS,
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