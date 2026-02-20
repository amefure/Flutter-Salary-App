import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/premium_time_line/premium_time_line_screen.dart';
import 'package:salary/feature/timeline/time_line_lock_screen.dart';

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
              final isLogin = ref.watch(authStateProvider).isLogin;
              final premiumState = ref.watch(premiumFunctionStateProvider);
              final isRelease = isLogin && premiumState.isPublicData && premiumState.isSubscribed;
              if (isRelease) {
                return const PremiumTimeLineScreen();
              } else {
                return const TimelineLockScreen();
              }
            }
        ),
      ),
    );
  }
}
