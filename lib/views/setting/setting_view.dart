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
                CupertinoListTile(
                  padding: EdgeInsets.all(20),
                  title: const CustomText(
                    text: "支払い元管理",
                    textSize: TextSize.MS,
                    fontWeight: FontWeight.bold,
                  ),
                  leading: const Icon(
                    CupertinoIcons.building_2_fill,
                    color: CustomColors.thema,
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => ListPaymentSourceView(),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  padding: EdgeInsets.all(20),
                  title: const CustomText(
                    text: "アプリロック",
                    textSize: TextSize.MS,
                    fontWeight: FontWeight.bold,
                  ),
                  leading: const Icon(
                    CupertinoIcons.lock_fill, // 鍵のアイコンに変更（好みで）
                    color: CustomColors.thema,
                  ),
                  trailing: CupertinoSwitch(
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
                CupertinoListTile(
                  padding: EdgeInsets.all(20),
                  title: const CustomText(
                    text: "アプリをレビューする",
                    textSize: TextSize.MS,
                    fontWeight: FontWeight.bold,
                  ),
                  leading: const Icon(
                    CupertinoIcons.hand_thumbsup,
                    color: CustomColors.thema,
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _launchURL("https://appdev-room.com/app"),
                ),
                CupertinoListTile(
                  padding: EdgeInsets.all(20),
                  title: const CustomText(
                    text: "アプリの不具合はこちら",
                    textSize: TextSize.MS,
                    fontWeight: FontWeight.bold,
                  ),
                  leading: const Icon(
                    CupertinoIcons.paperplane,
                    color: CustomColors.thema,
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap:
                      () => _openWebView(
                        context,
                        "https://appdev-room.com/contact",
                      ),
                ),
                CupertinoListTile(
                  padding: EdgeInsets.all(20),
                  title: const CustomText(
                    text: "利用規約とプライバシーポリシー",
                    textSize: TextSize.MS,
                    fontWeight: FontWeight.bold,
                  ),
                  leading: const Icon(
                    CupertinoIcons.calendar,
                    color: CustomColors.thema,
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap:
                      () => _openWebView(context, "https://appdev-room.com/"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
