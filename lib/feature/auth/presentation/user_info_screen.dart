import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/common/components/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/feature/auth/application/login/login_state.dart';
import 'package:salary/feature/auth/application/login/login_view_model.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';

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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();
  late final ProviderSubscription<LoginState> _subscription;

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
    _subscription = ref.listenManual<LoginState>(
      loginProvider,
      fireImmediately: true,
          (prev, next) {
        _syncController(_emailController, next.email);
        _syncController(_passWordController, next.password);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(loginProvider.notifier);
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
    final state = ref.watch(loginProvider);
    final viewModel = ref.read(loginProvider.notifier);

    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLogin == false && next.isLogin == true) {
        _showSuccessDialog(context);
      }
    });

    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [
          Column(
            spacing: 0,
            children: [
              Row(
                children: [

                  const Spacer(),

                  TextButton(onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const RegisterAccountScreen(),
                      ),
                    );
                  }, child: const CustomText(
                    text: '新規登録はこちら',
                    color: CustomColors.themaBlue,
                    fontWeight: FontWeight.bold,
                  )),

                  const Icon(Icons.arrow_forward_ios, color: CustomColors.themaBlue)
                ],
              ),

              /// メールアドレス入力ボックス
              CustomTextField(
                controller: _emailController,
                labelText: 'メールアドレス',
                prefixIcon: CupertinoIcons.mail_solid,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),

          /// パスワード入力ボックス
          CustomTextField(
            controller: _passWordController,
            labelText: 'パスワード',
            prefixIcon: CupertinoIcons.lock_fill,
            keyboardType: TextInputType.visiblePassword,
          ),

          CustomElevatedButton(
              text: 'ログインする',
              backgroundColor: state.isCompleted ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () {
                viewModel.login();
              }
          )
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('成功'),
          content: const Text('ログインしました。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}