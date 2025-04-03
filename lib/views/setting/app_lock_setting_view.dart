import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/repository/password_service.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/root_tab_view.dart';

class AppLockSettingView extends StatefulWidget {
  const AppLockSettingView({super.key, this.isEntry = true});
  final bool isEntry;
  @override
  _AppLockSettingViewState createState() => _AppLockSettingViewState();
}

class _AppLockSettingViewState extends State<AppLockSettingView> {
  final _passwordService = PasswordService();
  List<String> _input = [];
  final int _passwordLength = 4;

  /// パスワード登録成功アラート
  void _showSuccessAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("お知らせ"),
          content: const Text("パスワードでアプリをロックしました。"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
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
          title: const Text("Error"),
          content: const Text("パスワードが違います。"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _validatePassword() async {
    String? storedPassword = await _passwordService.getPassword();
    String password = _input.join('');
    if (storedPassword == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootTabViewView()),
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

  Future<void> _savePassword() async {
    if (_input.length == _passwordLength) {
      String password = _input.join('');
      await PasswordService().setPassword(password);
      _showSuccessAlert(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.isEntry ? "パスワード登録" : ""),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Row(
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
            ),

            const Spacer(),

            CustomElevatedButton(
              text: widget.isEntry ? "登録" : "解除",
              onPressed: () {
                if (_input.length == _passwordLength) {
                  if (widget.isEntry) {
                    _savePassword();
                  } else {
                    _validatePassword();
                  }
                }
              },
              backgroundColor:
                  _input.length == _passwordLength
                      ? CustomColors.thema
                      : CustomColors.themaGray,
            ),

            const Spacer(),

            Material(color: CustomColors.foundation, child: _buildNumberPad()),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
