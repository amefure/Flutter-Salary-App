import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/repository/biometrics_service.dart';
import 'package:salary/repository/password_service.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/root_tab_view.dart';

class AppLockSettingView extends StatefulWidget {
  const AppLockSettingView({super.key, this.isEntry = true});
  final bool isEntry;
  @override
  AppLockSettingViewState createState() => AppLockSettingViewState();
}

class AppLockSettingViewState extends State<AppLockSettingView> {
  final _passwordService = PasswordService();
  final _biometricsService = BiometricsService();
  final List<String> _input = [];
  final int _passwordLength = 4;

  @override
  void initState() {
    super.initState();
    // 登録ではない
    if (!widget.isEntry) {
      // 起動時に生体認証有効ユーザーには認証リクエスト
      _executeBiometricsAuth();
    }
  }

  /// パスワード登録成功アラート
  void _showSuccessAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('お知らせ'),
          content: const Text('パスワードでアプリをロックしました。'),
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

  /// パスワード認証失敗アラート
  void _showValidateErrorAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('パスワードが違います。'),
          actions: [
            TextButton(
              onPressed: () {
                // 入力パスワードを初期化
                _input.clear();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _validatePassword() async {
    String? storedPassword = await _passwordService.getPassword();
    String password = _input.join('');
    if (!mounted) return;
    if (storedPassword == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootTabViewView()),
      );
    } else {
      _showValidateErrorAlert(context);
    }
  }

  void _onKeyPress(String value) {
    if (value == 'delete' && _input.isNotEmpty) {
      setState(() {
        _input.removeLast();
      });
    } else if (_input.length < _passwordLength && value != 'delete') {
      setState(() {
        _input.add(value);
      });
    }
  }

  void _savePassword() async {
    if (_input.length == _passwordLength) {
      String password = _input.join('');
      await PasswordService().setPassword(password);
      if (!mounted) return;
      _showSuccessAlert(context);
    }
  }

  /// 生体認証で画面遷移
  void _executeBiometricsAuth() async {
    // 生体認証に挑戦
    bool isAuthenticated = await _biometricsService.authenticateWithBiometrics();
    // info: Don't use 'BuildContext's across async gaps警告
    // asyncメソッドでcontextを参照すると解放されている可能性があるため警告が出る
    // 使用前にmountedをチェックする
    if (!mounted) return;
    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootTabViewView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.isEntry ? 'パスワード登録' : ''),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // パスワード入力ボックス
            _passwordBox(),

            const Spacer(),

            // 生体認証ON / OFFでボタンのだしわけ
            // かつ 登録モードではない
            if (_biometricsService.isAvailable && !widget.isEntry && _input.length != _passwordLength)
            // パスワード認証ボタン
              SizedBox(
                height: 50,
                child:  _biometricsButton(),
              )
            else
            // パスワード認証ボタン
              SizedBox(
                height: 50,
                child: _passwordAuthButton(),
              ),

            const Spacer(),

            Material(color: CustomColors.foundation, child: _buildNumberPad()),
          ],
        ),
      ),
    );
  }

  /// パスワード表示用ボックスレイアウト
  Widget _passwordBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_passwordLength, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              index < _input.length
                  ? CustomColors.thema
                  : Colors.grey,
            ),
          ),
        );
      }),
    );
  }

  /// パスワード認証ボタン
  Widget _passwordAuthButton() {
    return CustomElevatedButton(
      text: widget.isEntry ? '登録' : '解除',
      onPressed: () async {
        if (_input.length == _passwordLength) {
          if (widget.isEntry) {
            // パスワード保存処理
            _savePassword();
          } else {
            // パスワード認証処理
            _validatePassword();
          }
        }
      },
      backgroundColor:
      _input.length == _passwordLength
          ? CustomColors.thema
          : CustomColors.themaGray,
    );
  }

  /// 生体認証処理
  Widget _biometricsButton() {
    return IconButton(
        onPressed: () async {
          _executeBiometricsAuth();
        },
        icon: const Icon(Icons.fingerprint, size: 50),
    );
  }

  Widget _buildNumberPad() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        List<String> keys = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '-',
          '0',
          'delete',
        ];
        String key = keys[index];
        return InkWell(
          onTap: () => _onKeyPress(key),
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.thema,
              border: Border.all(
                color: Colors.white, // 枠線の色
                width: 0.3, // 枠線の太さ
              ),
            ),

            alignment: Alignment.center,
            child:
                key == 'delete'
                    ? const Icon(Icons.backspace, color: Colors.white)
                    : CustomText(
                      text: key,
                      color: Colors.white,
                      textSize: TextSize.L,
                      fontWeight: FontWeight.bold,
                    ),
          ),
        );
      },
    );
  }
}
