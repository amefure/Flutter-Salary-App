import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/overlay/explanation_overlay.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium/premium_lock_screen.dart';
import 'package:salary/feature/premium/premium_root/premium_root_state.dart';
import 'package:salary/feature/premium/premium_root/premium_root_view_model.dart';
import 'package:salary/feature/premium/premium_summary/presentation/premium_summary_screen.dart';
import 'package:salary/feature/premium/premium_time_line/premium_time_line_screen.dart';
import 'package:salary/feature/premium/public_user_count_lock_screen.dart';

class PremiumRootScreen extends StatelessWidget {
  const PremiumRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: CupertinoNavigationBar(
        middle: const CustomText(
          text: 'プレミアム機能',
          fontWeight: FontWeight.bold,
        ),
        trailing: Consumer(
            builder: (context, ref, _) {
              return CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.refresh_circled,
                  size: 28,
                ),
                onPressed: () {
                  final viewModel = ref.read(premiumRootProvider.notifier);
                  viewModel.refresh();
                },
              );
            }),
      ),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final authState = ref.watch(authStateProvider);
            final premiumState = ref.watch(premiumFunctionStateProvider);

            final isRelease = authState.isLogin &&
                premiumState.isPublicData ||
                premiumState.isPremiumUnlocked;

            /// 🔒 Lockは絶対ここで判定
            if (!isRelease) {
              return const PremiumLockScreen();
            }

            /// 公開人数が一定数に達していないなら準備中とする
            if (!premiumState.isUnLimitedFunction) {
              return const PublicUserCountLockScreen();
            }

            final state = ref.watch(premiumRootProvider);
            final viewModel = ref.read(premiumRootProvider.notifier);

            return Column(
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 30),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CupertinoSlidingSegmentedControl<
                            PremiumTab>(
                          groupValue: state.currentTab,
                          children: const {
                            PremiumTab.timeline: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: CustomText(
                                text: 'タイムライン',
                                textSize: TextSize.S,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PremiumTab.summary: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: CustomText(
                                text: '集計',
                                textSize: TextSize.S,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          },
                          onValueChanged: (value) {
                            if (value != null) {
                              viewModel.updateTab(value);
                            }
                          },
                        ),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: 30,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            CupertinoIcons.question_circle_fill,
                            size: 28,
                          ),
                          onPressed: () {
                            final currentTab = state.currentTab;

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

                /// タブ切替
                Expanded(
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 250),
                    child: state.currentTab ==
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
