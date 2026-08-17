import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/analysis/components/comparison_view.dart';
import 'package:salary/feature/analysis/components/item_summary_view.dart';
import 'package:salary/feature/premium/premium_lock_screen.dart';

class SalaryAnalysisScreen extends ConsumerStatefulWidget {
  const SalaryAnalysisScreen({super.key});

  @override
  ConsumerState<SalaryAnalysisScreen> createState() => _SalaryAnalysisScreenState();
}

class _SalaryAnalysisScreenState extends ConsumerState<SalaryAnalysisScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: '給料解析(プレミアム)',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final authState = ref.watch(authStateProvider);
            final premiumState = ref.watch(premiumFunctionStateProvider);

            // プレミアム機能（または公開データ許可など）の判定
            final isRelease = authState.isLogin &&
                (premiumState.isPublicData || premiumState.isPremiumFullUnlocked);

            /// 🔒 未開放の場合はプレミアムロック画面を表示
            if (!isRelease) {
              return const PremiumLockScreen(isAnalytics: true);
            }

            // 開放されている場合は通常の解析画面（セグメント・グラフ等）を表示
            return Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _selectedSegment,
                      children: const {
                        0: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('月別比較', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        1: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('項目別累計', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      },
                      onValueChanged: (value) {
                        if (value != null) setState(() => _selectedSegment = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _selectedSegment == 0 ? const ComparisonView() : const ItemSummaryView(),
                ),
                const AdMobBannerWidget(),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}