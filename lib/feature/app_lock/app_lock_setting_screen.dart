import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/repository/biometrics_service.dart';
import 'package:salary/core/repository/password_repository.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/app_lock/app_lock_setting_state.dart';
import 'package:salary/feature/app_lock/app_lock_setting_view_model.dart';
import 'package:salary/feature/root/root_tab_view.dart';

enum _KeypadType {
  one('1'),
  two('2'),
  three('3'),
  four('4'),
  five('5'),
  six('6'),
  seven('7'),
  eight('8'),
  nine('9'),
  empty('-'),
  zero('0'),
  delete('delete');

  const _KeypadType(this.label);
  final String label;

  /// 数字かどうか
  bool get isNumber => int.tryParse(label) != null;
  /// 削除ボタンか
  bool get isDelete => this == _KeypadType.delete;
  /// 空白（反応させないボタン）か
  bool get isEmpty => this == _KeypadType.empty;
}

class AppLockSettingScreen extends ConsumerWidget {
  const AppLockSettingScreen({super.key, this.isEntry = true});
  final bool isEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = appLockSettingProvider(isEntry);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    /// 認証成功時のハンドリング
    listerIsAuthenticated(context, ref, provider);
    /// 認証失敗時のハンドリング
    ref.listen<bool>(provider.select((s) => s.isFailed),
          (previous, next) async {
        if (next) {
          final _ = await AppDialog.show(
            context: context,
            message: '認証に失敗しました。再度認証してください。',
            type: DialogType.error,
          );
          ref.read(provider.notifier).resetIsFailed();
        }
      },
    );

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: CupertinoNavigationBar(
        middle: CustomText(
          text: isEntry ? 'パスワード登録' : '',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // パスワード入力ボックス
            _passwordBox(state),

            const Spacer(),

            // 生体認証ON / OFFでボタンのだしわけ
            // かつ 登録モードではない
            if (state.isBiometricsAvailable && !isEntry && !state.isInputComplete)
              /// 生体認証ボタン
              SizedBox(
                height: 50,
                child: _biometricsButton(viewModel),
              )
            else
              /// パスワード認証ボタン
              SizedBox(
                height: 50,
                child: _passwordAuthButton(state.isInputComplete, viewModel),
              ),

            const Spacer(),

            Material(
                color: CustomColors.foundation(context),
                child: _buildNumberPad(viewModel)
            ),
          ],
        ),
      ),
    );
  }

  void listerIsAuthenticated(
      BuildContext context,
      WidgetRef ref,
      ProviderListenable<AppLockSettingState> provider,
  ) {
    ref.listen<bool>(provider.select((s) => s.isAuthenticated), (previous, next) async {
        if (next) {
          if (isEntry) {
            /// 登録モードならダイアログを表示して終了
            final _ = await AppDialog.show(
              context: context,
              message: 'パスワードでアプリをロックしました。',
              type: DialogType.success,
            );
            // 成功時にはtrueを明示的に返す
            Navigator.of(context).pop(true);
          } else {
            /// 通常遷移ならタブルートに飛ばす
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RootTabView()),
            );
          }
        }
      },
    );
  }


  /// パスワード表示用ボックスレイアウト
  Widget _passwordBox(AppLockSettingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(AppLockSettingState.passwordLength, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < state.inputPassword.length
                  ? CustomColors.thema
                  : Colors.grey,
            ),
          ),
        );
      }),
    );
  }

  /// パスワード認証ボタン
  Widget _passwordAuthButton(
      bool isInputComplete,
      AppLockSettingViewModel viewModel
      ) {
    return CustomElevatedButton(
      text: isEntry ? '登録' : '解除',
      onPressed: () async {
        if (isEntry) {
          // パスワード保存処理
          viewModel.savePassword();
        } else {
          // パスワード認証処理
          viewModel.executeInputPassword();
        }
      },
      backgroundColor: isInputComplete ? CustomColors.thema : CustomColors.themaGray,
    );
  }

  /// 生体認証処理
  Widget _biometricsButton(AppLockSettingViewModel viewModel) {
    return IconButton(
      onPressed: () async {
        viewModel.executeBiometricsAuth();
      },
      icon: const Icon(Icons.fingerprint, size: 50),
    );
  }

  Widget _buildNumberPad(
      AppLockSettingViewModel viewModel
      ) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
      ),
      itemCount: _KeypadType.values.length,
      itemBuilder: (context, index) {
        final keyType = _KeypadType.values[index];

        return InkWell(
          onTap: () => _onKeyPress(keyType, viewModel),
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.thema,
              border: Border.all(
                color: Colors.white,
                width: 0.3,
              ),
            ),

            alignment: Alignment.center,
            child:
            keyType.isDelete
                ? const Icon(Icons.backspace, color: Colors.white)
                : CustomText(
              text: keyType.label,
              color: Colors.white,
              textSize: TextSize.L,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  void _onKeyPress(_KeypadType keyType, AppLockSettingViewModel viewModel) {
    if (keyType.isDelete) {
      viewModel.removeLast();
    } else if (keyType.isNumber) {
      viewModel.addPassword(keyType.label);
    }
  }
}

