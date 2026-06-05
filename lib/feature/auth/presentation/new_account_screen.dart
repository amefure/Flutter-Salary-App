import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/feature/auth/application/new_account/new_account_state.dart';
import 'package:salary/feature/auth/application/new_account/new_account_view_model.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/auth/presentation/login_screen.dart';

class NewAccountScreen extends StatelessWidget {
  const NewAccountScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: '新規アカウント作成(メール認証)',
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
  late final ProviderSubscription<NewAccountState> _subscription;

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
    _subscription = ref.listenManual<NewAccountState>(
      newAccountProvider,
      fireImmediately: true,
          (prev, next) {
        _syncController(_emailController, next.email);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(newAccountProvider.notifier);
    // 入力されたらViewModelに反映
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
    final state = ref.watch(newAccountProvider);
    final viewModel = ref.read(newAccountProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        children: [

          const CustomText(
            text: 'アカウント作成にはメール認証が必要です。ボタン押下後に届いたメール内のリンクからアプリに戻り、本登録を進めてください。',
            textSize: TextSize.S,
            maxLines: 4,
          ),

          Column(
            spacing: 0,
            children: [
              Row(
                children: [

                  const Spacer(),

                  TextButton(onPressed: () async {
                    final state = ref.watch(authStateProvider);
                    if (!state.isLogin) {
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    } else {
                      final _ = await AppDialog.show(
                          context: context,
                          message: 'すでにログイン済みです。',
                          type: DialogType.error
                      );
                    }
                  }, child: const CustomText(
                    text: 'ログインはこちら',
                    color: CustomColors.themaBlue,
                    fontWeight: FontWeight.bold,
                    textSize: TextSize.S,
                  )),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: CustomColors.themaBlue,
                    size: 18,
                  )
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

          CustomElevatedButton(
              text: '仮登録する',
              backgroundColor: state.isCompleted && !state.isSend ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () async {
                final state = ref.watch(authStateProvider);
                if (!state.isLogin) {
                  final result = await viewModel.registerSendEmail();
                  if (result) {
                    final _ = await AppDialog.show(
                        context: context,
                        message: '仮登録メールを送信しました。',
                        type: DialogType.success
                    );
                  }
                } else {
                  final _ = await AppDialog.show(
                      context: context,
                      message: 'すでにログイン済みです。',
                      type: DialogType.error
                  );
                }
              }
          )
        ],
      ),
    );
  }
}