

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  TimelineLockScreen()
                ],
              );
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Icon(
            CupertinoIcons.lock_fill,
            size: 36,
            color: CustomColors.themaOrange,
          ),

          const SizedBox(height: 16),

          /// タイトル
          CustomText(
            text: 'プレミアムタイムライン',
            textSize: TextSize.L,
            fontWeight: FontWeight.bold,
          ),

          const SizedBox(height: 8),

          /// サブコピー
          CustomText(
            text: 'あなたの市場価値を、データで可視化。',
            textSize: TextSize.M,
            fontWeight: FontWeight.w600,
          ),

          const SizedBox(height: 8),

          CustomText(
            text:
            '同年代・同業種のリアルな給与データから\n'
                '今の立ち位置と未来の可能性が見えてきます。',
            textSize: TextSize.S,
            color: CupertinoColors.systemGrey,
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          /// 機能説明
          _PremiumPoint(
            icon: CupertinoIcons.money_yen_circle_fill,
            title: '月々のリアル給与を閲覧',
            description: 'みんなの実際の月収データをチェック',
          ),

          const SizedBox(height: 12),

          _PremiumPoint(
            icon: CupertinoIcons.chart_bar_alt_fill,
            title: '同年代の年収ランキング',
            description: '自分のポジションが一目で分かる',
          ),

          const SizedBox(height: 12),

          _PremiumPoint(
            icon: CupertinoIcons.gift_fill,
            title: 'ボーナス相場を確認',
            description: '業界ごとの支給実績を比較',
          ),

          const SizedBox(height: 24),

          /// 条件ステップ
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
            title: 'プレミアム登録(初回ユーザー限定無料開放)',
            isCompleted: authState.isLogin,
          ),

          const SizedBox(height: 24),

          if (!authState.isLogin)
            CustomText(
              text: 'すべての条件を満たすと\nタイムラインが利用できます。',
              textSize: TextSize.S,
              color: CupertinoColors.systemGrey,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: CustomColors.themaBlue,
        ),
        const SizedBox(width: 12),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 20),
          CircleAvatar(
            radius: 14,
            backgroundColor: isCompleted
                ? CustomColors.themaBlue
                : CustomColors.themaBlack,
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
          const SizedBox(width: 12),
          CustomText(
            text: title,
            textSize: TextSize.M,
            color: CustomColors.text(context)
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

