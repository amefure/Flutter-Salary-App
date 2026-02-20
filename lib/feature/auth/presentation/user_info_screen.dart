import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/app_dialog.dart';
import 'package:salary/core/common/components/cupertino_date_picker_modal.dart';
import 'package:salary/core/common/components/cupertino_picker_modal.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/user_info_row_tile.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/application/user_info/user_info_state.dart';
import 'package:salary/feature/auth/application/user_info/user_info_view_model.dart';
import 'package:salary/core/config/profile_config.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: CupertinoNavigationBar(
          middle: const CustomText(
            text: 'アカウント情報',
            fontWeight: FontWeight.bold,
          ),
        trailing: Consumer(
            builder: (context, ref, _) {
              final isEdit = ref.watch(userInfoProvider).isEdit;
              final viewModel = ref.read(userInfoProvider.notifier);
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  viewModel.toggleIsEdit();
                },
                child: Icon(
                    isEdit ? CupertinoIcons.xmark_circle : CupertinoIcons.pencil_circle_fill,
                    size: 28
                ),
              );
            }
        ),
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


  final TextEditingController _nameController = TextEditingController();
  late final ProviderSubscription<UserInfoState> _subscription;

  @override
  void initState() {
    super.initState();
    // TextEditingController =>(変化) ViewModel.Stateと同期
    _bindControllersToState();
    // ViewModel.State =>(変化) TextEditingControllerと同期
    _bindStateToControllers();
  }

  /// ViewModel.State =>(変化) TextEditingControllerと同期
  void _bindStateToControllers() {
    _subscription = ref.listenManual<UserInfoState>(
      userInfoProvider,
      fireImmediately: true,
          (prev, next) {
        _syncController(_nameController, next.name);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(userInfoProvider.notifier);
    // 入力されたらViewModelに反映
    _nameController.addListener(() {
      vm.updateName(_nameController.text);
    });
  }

  @override
  void dispose() {
    _subscription.close();
    _nameController.dispose();
    super.dispose();
  }

  void _syncController(
      TextEditingController controller,
      String newValue,
      ) {
    if (controller.text == newValue) return;

    // build外 & フレーム後に安全に更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.text = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userInfoProvider);
    final viewModel = ref.read(userInfoProvider.notifier);
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [

          /// アカウント名
          CustomTextField(
            controller: _nameController,
            labelText: 'アカウント名',
            readOnly: !state.isEdit,
            prefixIcon: CupertinoIcons.person_crop_square_fill,
            keyboardType: TextInputType.name,
          ),

          /// メールアドレスはreadOnlyのみ(編集不可)
          CustomTextField(
            controller: TextEditingController(text: state.email),
            labelText: 'メールアドレス(変更不可)',
            readOnly: true,
            prefixIcon: CupertinoIcons.mail_solid,
            keyboardType: TextInputType.emailAddress,
          ),

          /// 都道府県
          UserInfoRowTile(
              title: '都道府県',
              value: state.region,
              isEdit: state.isEdit,
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
              isEdit: state.isEdit,
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
            isEdit: state.isEdit,
            onTap: () =>
              CupertinoPickerModal.show<String>(
                context: context,
                items: ProfileConfig.jobs,
                currentValue: state.job,
                labelBuilder: (job) => job,
                onSelected: viewModel.updateJob,
              )
          ),

        if (state.isEdit)
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
