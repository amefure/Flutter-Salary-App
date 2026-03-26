import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium/premium_lock_screen.dart';

class NewPremiumFeatureDialog extends ConsumerWidget {
  final VoidCallback onDetailButtonPressed;
  final VoidCallback onCloseButtonPressed;

  const NewPremiumFeatureDialog({
    super.key,
    required this.onDetailButtonPressed,
    required this.onCloseButtonPressed,
  });

  static Future<void> show(
      BuildContext context,
  {
    required VoidCallback onDetailButtonPressed,
    required VoidCallback onCloseButtonPressed
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeIn),
            child: child,
          ),
        );
      },
      pageBuilder: (context, _, _) => NewPremiumFeatureDialog(
        onDetailButtonPressed: onDetailButtonPressed,
        onCloseButtonPressed: onCloseButtonPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // メインコンテンツ全体
            Container(
              decoration: BoxDecoration(
                color: CustomColors.background(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    /// ヘッダー
                    const CustomText(
                      text: '新機能が追加されました！',
                      textSize: TextSize.L,
                      color: CustomColors.thema,
                      fontWeight: FontWeight.bold,
                    ),
                    /// プレミアム機能カードUI
                    const PremiumCard(),
                    const Divider(height: 1),
                    /// 下部ボタン群
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomElevatedButton(
                            text: '詳細を見る',
                            backgroundColor: CustomColors.thema,
                            onPressed: () {
                              Navigator.pop(context);
                              onDetailButtonPressed();
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onCloseButtonPressed();
                            },
                            child: const CustomText(
                              text: '閉じる',
                              textSize: TextSize.S,
                              color: CupertinoColors.systemGrey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 「NEW!」ラベル
            Positioned(
              top: -14,
              left: -14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CustomColors.negative,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CustomText(
                  text: 'NEW!',
                  color: CupertinoColors.white,
                  textSize: TextSize.S,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}