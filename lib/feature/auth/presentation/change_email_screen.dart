import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/application/change_email/change_email_state.dart';
import 'package:salary/feature/auth/application/change_email/change_email_view_model.dart';
import 'package:salary/feature/auth/application/user_info/user_info_state.dart';
import 'package:salary/feature/auth/application/user_info/user_info_view_model.dart';

class ChangeEmailScreen extends StatelessWidget {
  const ChangeEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: 'メールアドレス変更',
          fontWeight: FontWeight.bold,
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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();
  late final ProviderSubscription<ChangeEmailState> _subscription;

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
    _subscription = ref.listenManual<ChangeEmailState>(
      changeEmailProvider,
      fireImmediately: true,
          (prev, next) {
        _syncController(_emailController, next.newEmail);
        _syncController(_passWordController, next.password);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(changeEmailProvider.notifier);
    // 入力されたらViewModelに反映
    _emailController.addListener(() {
      vm.updateEmail(_emailController.text);
    });
    _passWordController.addListener(() {
      vm.updatePassWord(_passWordController.text);
    });
  }

  @override
  void dispose() {
    _subscription.close();
    _emailController.dispose();
    _passWordController.dispose();
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
    final state = ref.watch(changeEmailProvider);
    final viewModel = ref.read(changeEmailProvider.notifier);
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [

          /// 現在のメールアドレスはreadOnlyのみ(編集不可)
          CustomTextField(
            controller: TextEditingController(text: state.oldEmail),
            labelText: '現在のメールアドレス',
            readOnly: true,
            prefixIcon: CupertinoIcons.mail_solid,
            keyboardType: TextInputType.emailAddress,
          ),

          /// 新規メールアドレス
          CustomTextField(
            controller: _emailController,
            labelText: '新規メールアドレス',
            prefixIcon: CupertinoIcons.mail_solid,
            keyboardType: TextInputType.emailAddress,
          ),

          /// パスワード入力ボックス
          CustomTextField(
            controller: _passWordController,
            labelText: 'パスワード',
            prefixIcon: CupertinoIcons.lock_fill,
            keyboardType: TextInputType.visiblePassword,
          ),


          CustomElevatedButton(
              text: '変更する',
              backgroundColor: state.isCompleted ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () async {
                final result = await viewModel.requestChangeEmail();
                if (result) {
                  final _ = await AppDialog.show(
                      context: context,
                      message: 'メールアドレスを変更しました。',
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
