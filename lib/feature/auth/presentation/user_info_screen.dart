import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/application/user_info/user_info_view_model.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: 'アカウント情報',
            fontWeight: FontWeight.bold,
          )
      ),
      child: const SafeArea(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: _BodyWidget()
          )
      ),
    );
  }
}

class _BodyWidget extends ConsumerStatefulWidget {
  const _BodyWidget();

  @override
  ConsumerState<_BodyWidget> createState() => _Body();
}


class _Body extends ConsumerState<_BodyWidget> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [

          if (user != null)
            CustomText(text: user.name),

          if (user != null)
            CustomText(text: user.email),

          if (user != null)
            CustomText(text: user.region),

          if (user != null)
            CustomText(text: UserInfoViewModel().displayDate(user.birthday)),

        ],
      ),
    );
  }
}