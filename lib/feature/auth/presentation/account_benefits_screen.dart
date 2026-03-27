import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/header_visual_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/presentation/login_screen.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';

class AccountBenefitsScreen extends StatelessWidget {
  const AccountBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: 'アカウント作成のメリット',
            fontWeight: FontWeight.bold,
          )
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              /// 1. ヘッダービジュアル（流用）
              const HeaderVisualView(
                  icon: CupertinoIcons.gift_alt_fill
              ),

              const SizedBox(height: 32),

              /// 2. メリットカード：バックアップ
              const _BenefitCard(
                title: 'データのバックアップ',
                description: '機種変更やアプリの再インストール時も安心。大切な給料データをクラウドに安全に保存します。',
                // 注意書きを分離して渡す
                caution: 'クラウドに保存されるのは公開しているデータのみです。',
                icon: CupertinoIcons.cloud_upload_fill,
                accentColor: CustomColors.themaBlue,
              ),

              const SizedBox(height: 16),

              /// 3. メリットカード：プレミアム
              const _BenefitCard(
                title: 'プレミアム機能への加入',
                description: '同年代との比較分析や、詳細な統計レポートなど、あなたのキャリアを加速させる全ての機能が解放対象になります。',
                caution: 'プレミアム機能の完全解放には別条件も満たす必要があります。',
                icon: CupertinoIcons.star_fill,
                accentColor: CustomColors.themaOrange,
              ),

              const SizedBox(height: 40),

              CustomElevatedButton(
                  text: '今すぐアカウントを作成',
                  backgroundColor: ThemaColor.blue.color,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (context) => const RegisterAccountScreen(),
                      ),
                    );
                  }
              ),

              const SizedBox(height: 8),

              TextButton(onPressed: () {
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }, child: const CustomText(
                text: 'ログインはこちら',
                color: CustomColors.themaBlue,
                fontWeight: FontWeight.bold,
                textSize: TextSize.S,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final String title;
  final String description;
  final String caution;
  final IconData icon;
  final Color accentColor;

  const _BenefitCard({
    required this.title,
    required this.description,
    required this.caution,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          /// 1. メインコンテンツ（アイコン + テキスト）
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// アイコン部分
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                /// テキスト部分
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        textSize: TextSize.M,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        text: description,
                        textSize: TextSize.S,
                        color: CupertinoColors.systemGrey,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CustomColors.themaOrange.withAlpha(50),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.info_circle,
                  size: 18,
                  color: CustomColors.themaOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: caution,
                    textSize: TextSize.SS,
                    color: CustomColors.themaOrange,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}