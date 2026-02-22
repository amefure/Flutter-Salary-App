import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/overlay/explanation_overlay.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium_root/premium_lock_screen.dart';
import 'package:salary/feature/premium_summary/premium_summary_screen.dart';
import 'package:salary/feature/premium_time_line/premium_time_line_screen.dart';

class PremiumRootScreen extends StatelessWidget {
  const PremiumRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: 'プレミアム機能',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final authState = ref.watch(authStateProvider);
            final premiumState =
            ref.watch(premiumFunctionStateProvider);

            final isRelease = authState.isLogin &&
                premiumState.isPublicData &&
                premiumState.isSubscribed;

            /// 🔒 Lockは絶対ここで判定
            if (!isRelease) {
              return const PremiumLockScreen();
            }

            /// 🔓 ここからPremium表示
            final currentTab =
            ref.watch(premiumTabProvider);

            return Column(
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 30),
                      const Spacer(),
                      /// 🔥 上部タブ
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CupertinoSlidingSegmentedControl<
                            PremiumTab>(
                          groupValue: currentTab,
                          children: const {
                            PremiumTab.timeline: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Text('タイムライン'),
                            ),
                            PremiumTab.summary: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Text('集計'),
                            ),
                          },
                          onValueChanged: (value) {
                            if (value != null) {
                              ref.read(premiumTabProvider.notifier).state = value;
                            }
                          },
                        ),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: 30,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.question_circle_fill),
                          onPressed: () {
                            final currentTab = ref.read(premiumTabProvider);

                            ExplanationOverlay.show(
                              context: context,
                              title: currentTab.title,
                              description: currentTab.description,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔥 タブ切替
                Expanded(
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 250),
                    child: currentTab ==
                        PremiumTab.timeline
                        ? const PremiumTimeLineScreen()
                        : const PremiumSummaryScreen(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final premiumTabProvider =
StateProvider<PremiumTab>((ref) {
  return PremiumTab.timeline;
});

enum PremiumTab {
  timeline(
    title: 'タイムライン',
    description: 'みんなの月単位での給料情報投稿を時系列で確認できます。\n最新の情報をすぐチェックできます。',
  ),
  summary(
    title: 'サマリー',
    description: '月別・年別のデータを\nグラフで確認できます。',
  );

  final String title;
  final String description;

  const PremiumTab({
    required this.title,
    required this.description,
  });
}




