import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/feature/auth/application/login/login_state.dart';
import 'package:salary/feature/auth/application/login/login_view_model.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/application/password_reset/password_reset_state.dart';
import 'package:salary/feature/auth/application/password_reset/password_reset_view_model.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: 'パスワードリセット',
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

  final TextEditingController _emailController = TextEditingController();
  late final ProviderSubscription<PasswordResetState> _subscription;

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
    _subscription = ref.listenManual<PasswordResetState>(
      passwordResetProvider,
      fireImmediately: true,
          (prev, next) {
        _syncController(_emailController, next.email);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(passwordResetProvider.notifier);
    _emailController.addListener(() {
      vm.updateEmail(_emailController.text);
    });
  }

  @override
  void dispose() {
    _subscription.close();
    _emailController.dispose();
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
    final state = ref.watch(passwordResetProvider);
    final viewModel = ref.read(passwordResetProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        children: [

          /// メールアドレス入力ボックス
          CustomTextField(
            controller: _emailController,
            labelText: 'メールアドレス',
            prefixIcon: CupertinoIcons.mail_solid,
            keyboardType: TextInputType.emailAddress,
          ),

          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: CustomText(
              text: 'ユーザー登録しているメールアドレスに対してパスワードリセットメールを送信します。\nメールに記載のリンクからパスワードをリセットしてください。',
              textSize: TextSize.S,
              fontWeight: FontWeight.bold,
              maxLines: 7,
            ),
          ),

          CustomElevatedButton(
              text: state.isSend ? '送信済み' : '送信する',
              backgroundColor: state.isCompleted && !state.isSend ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () async {
                final result = await viewModel.sendResetMail();
                if (result) {
                  final _ = await AppDialog.show(
                      context: context,
                      message: 'パスワードリセットメールを送信しました。',
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