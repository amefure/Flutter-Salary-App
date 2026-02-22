import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/common/components/cupertino_date_picker_modal.dart';
import 'package:salary/core/common/components/cupertino_picker_modal.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/feature/auth/presentation/components/user_info_row_tile.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/feature/auth/application/register_account/register_account_view_model.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/application/register_account/register_account_state.dart';
import 'package:salary/feature/auth/presentation/components/job_picker_modal.dart';

class RegisterAccountScreen extends StatelessWidget {
  const RegisterAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation(context),
        navigationBar: const CupertinoNavigationBar(
            middle: CustomText(
              text: '新規アカウント作成',
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();
  final TextEditingController _passWordConfirmController = TextEditingController();
  late final ProviderSubscription<RegisterAccountState> _subscription;

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
    _subscription = ref.listenManual<RegisterAccountState>(
      registerAccountProvider,
      fireImmediately: true,
          (prev, next) {
        _syncController(_nameController, next.name);
        _syncController(_emailController, next.email);
        _syncController(_passWordController, next.password);
        _syncController(_passWordConfirmController, next.passwordConfirm);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(registerAccountProvider.notifier);
    // 入力されたらViewModelに反映
    _nameController.addListener(() {
      vm.updateName(_nameController.text);
    });
    _emailController.addListener(() {
      vm.updateEmail(_emailController.text);
    });
    _passWordController.addListener(() {
      vm.updatePassWord(_passWordController.text);
    });
    _passWordConfirmController.addListener(() {
      vm.updatePassWordConfirm(_passWordConfirmController.text);
    });
  }

  @override
  void dispose() {
    _subscription.close();
    _nameController.dispose();
    _emailController.dispose();
    _passWordController.dispose();
    _passWordConfirmController.dispose();
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
    final state = ref.watch(registerAccountProvider);
    final viewModel = ref.read(registerAccountProvider.notifier);

    ref.listen(authStateProvider, (previous, next) async {
      if (previous?.isLogin == false && next.isLogin == true) {
        final _ = await AppDialog.show(
          context: context,
          message: 'アカウントを作成しました。',
          type: DialogType.success
        );
        // 画面戻る
        Navigator.of(context).pop();
      }
    });

    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [

          /// アカウント名
          CustomTextField(
            controller: _nameController,
            labelText: 'アカウント名',
            prefixIcon: CupertinoIcons.person_crop_square_fill,
            keyboardType: TextInputType.name,
          ),

          /// メールアドレス入力ボックス
          CustomTextField(
            controller: _emailController,
            labelText: 'メールアドレス',
            prefixIcon: CupertinoIcons.mail_solid,
            keyboardType: TextInputType.emailAddress,
          ),

          Column(
            children: [
              /// パスワード入力ボックス
              CustomTextField(
                controller: _passWordController,
                labelText: 'パスワード',
                prefixIcon: CupertinoIcons.lock_fill,
                keyboardType: TextInputType.visiblePassword,
              ),

              const SizedBox(height: 24),

              /// パスワード確認用入力ボックス
              CustomTextField(
                controller: _passWordConfirmController,
                labelText: 'パスワード確認用',
                prefixIcon: CupertinoIcons.lock_fill,
                keyboardType: TextInputType.visiblePassword,
              ),

              const CustomText(
                text: 'パスワードは8文字以上で、英数字を混載したものを使用してください',
                textSize: TextSize.SS,
                maxLines: 2,
              )
            ],
          ),

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
            value: state.job.name,
            onTap: () async {
              final selected = await showModalBottomSheet<Job>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => JobPickerModal(currentJob: state.job),
              );

              if (selected != null) {
                viewModel.updateJob(selected);
              }
            }
          ),

          CustomElevatedButton(
              text: '登録する',
              backgroundColor: state.isCompleted ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () {
                viewModel.registerAccount();
              }
          )
        ],
      ),
    );
  }
}