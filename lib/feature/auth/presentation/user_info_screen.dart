import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/app_dialog.dart';
import 'package:salary/core/common/components/cupertino_date_picker_modal.dart';
import 'package:salary/core/common/components/cupertino_picker_modal.dart';
import 'package:salary/core/common/components/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/common/components/user_info_row_tile.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/application/user_info/user_info_view_model.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';
import 'package:salary/core/config/profile_config.dart';

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
    final state = ref.watch(userInfoProvider);
    final viewModel = ref.read(userInfoProvider.notifier);
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [
          CustomText(text: state.name),

          CustomText(text: state.email),

          /// 都道府県
          UserInfoRowTile(
            title: '都道府県',
            value: state.region,
            onTap: () =>
              CupertinoPickerModal.show<String>(
                context: context,
                items: ProfileConfig.prefectures,
                currentValue: state.region,
                labelBuilder: (region) => region,
                onSelected: viewModel.updateRegion,
              )
          ),

          /// 生年月日
          UserInfoRowTile(
              title: '生年月日',
              value: viewModel.displayDate(state.birthday),
              onTap: () {
                final date = state.birthday ?? ProfileConfig.defaultDateTime;

                viewModel.updateBirthday(date);

                CupertinoDatePickerModal.show(
                  context: context,
                  initialDate: date,
                  onSelected: viewModel.updateBirthday,
                );
              }
          ),

          /// 職業
          UserInfoRowTile(
            title: '職業',
            value: state.job,
            onTap: () =>
              CupertinoPickerModal.show<String>(
                context: context,
                items: ProfileConfig.jobs,
                currentValue: state.job,
                labelBuilder: (job) => job,
                onSelected: viewModel.updateJob,
              )
          ),

        CustomElevatedButton(
              text: '更新する',
              backgroundColor: state.isCompleted ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () async {
                final result = await viewModel.updateUserInfo();
                if (result) {
                  final _ = await AppDialog.show(
                      context: context,
                      message: 'プロフィールを更新しました。',
                      type: DialogType.success
                  );
                }
              }
          )
        ],
      ),
    );
  }
}
