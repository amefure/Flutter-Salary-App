import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/repository/password_service.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/views/components/custom_text_view.dart';
import 'package:salary/views/setting/app_lock_setting_view.dart';
import 'package:salary/views/setting/list_payment_source_view.dart';
import 'package:salary/views/webview/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  bool _isAppLockEnabled = false; // アプリロックの状態を管理

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    bool isEnabled = await PasswordService().isLockEnabled();
    setState(() {
      _isAppLockEnabled = isEnabled;
    });
  }

  /// ブラウザでURLを起動する
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// WebViewで対象URLを起動する
  void _openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => WebViewScreen(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation,
      navigationBar: const CupertinoNavigationBar(middle: Text("設定")),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const CustomText(text: "App"),
              children: [
                _settingListTile("支払い元管理", CupertinoIcons.building_2_fill, () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ListPaymentSourceView(),
                    ),
                  );
                }),

                _settingListTile(
                  "アプリロック",
                  CupertinoIcons.lock_fill,
                  null,
                  CupertinoSwitch(
                    activeTrackColor: CustomColors.thema,
                    value: _isAppLockEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        PasswordService().removePassword();
                        _isAppLockEnabled = value;
                      });
                      if (value) {
                        // スイッチがONになったらモーダル表示
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => AppLockSettingView(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            CupertinoListSection.insetGrouped(
              header: const CustomText(text: "LINK"),
              footer: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CustomText(
                  text: "・アプリに不具合がございましたら「アプリの不具合はこちら」よりお問い合わせください。",
                  textSize: TextSize.S,
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                ),
              ),
              children: [
                _settingListTile(
                  "アプリをレビューする",
                  CupertinoIcons.hand_thumbsup,
                  () {
                    _launchURL("https://appdev-room.com/app");
                  },
                ),

                _settingListTile("アプリの不具合はこちら", CupertinoIcons.paperplane, () {
                  _openWebView(context, "https://appdev-room.com/contact");
                }),

                _settingListTile(
                  "利用規約とプライバシーポリシー",
                  CupertinoIcons.calendar,
                  () {
                    _openWebView(context, "https://appdev-room.com/");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 設定リスト行UI
  Widget _settingListTile(
    String title,
    IconData icon,
    VoidCallback? action, [
    Widget trailing = const CupertinoListTileChevron(),
  ]) {
    return CupertinoListTile(
      padding: const EdgeInsets.all(20),
      title: CustomText(
        text: title,
        textSize: TextSize.MS,
        fontWeight: FontWeight.bold,
      ),
      leading: Icon(icon, color: CustomColors.thema),
      trailing: trailing,
      onTap: () => action,
    );
  }
}
