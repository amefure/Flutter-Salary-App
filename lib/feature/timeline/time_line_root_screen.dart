import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
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
              final isLogin = ref.watch(authControllerProvider).isLogin;
              return const TimelineLockScreen();
            }
        ),
      ),
    );
  }
}
