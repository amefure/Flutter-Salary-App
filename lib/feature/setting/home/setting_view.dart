import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/providers/theme_mode_notifier.dart';
import 'package:salary/feature/auth/presentation/login_screen.dart';
import 'package:salary/feature/auth/presentation/user_info_screen.dart';
import 'package:salary/feature/setting/home/setting_view_model.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/feature/setting/app_lock_setting_view.dart';
import 'package:salary/feature/setting/in_app_purchase/in_app_purchase_view.dart';
import 'package:salary/feature/setting/list_payment_source_view.dart';
import 'package:salary/feature/webview/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// abstractでインスタンス化できないクラスとして定義する
abstract class _StaticUrl {
  static const String termsOfService = 'https://appdev-room.com/app-terms-of-service';
  static const String storeRequestReview = 'https://apps.apple.com/jp/app/%E3%82%B7%E3%83%B3%E3%83%97%E3%83%AB%E7%B5%A6%E6%96%99%E8%A8%98%E9%8C%B2/id6744486398?action=write-review';
  static const String contact = 'https://appdev-room.com/contact';
}

class SettingView extends StatelessWidget {

  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
          middle: CustomText(
            text: '設定',
            fontWeight: FontWeight.bold,
          )
      ),
      child: SafeArea(
        child: ListView(
          children: [
            _appSection(context),
            _myMenuSection(context),
            _linkSection(context),
          ],
        ),
      ),
    );
  }

  Widget _appSection(BuildContext context) {
    return  CupertinoListSection.insetGrouped(
      header: const CustomText(text: 'アプリ設定'),
      backgroundColor: CustomColors.foundation(context),
      children: [
        _settingListTile(
            context,
            '支払い元管理',
            CupertinoIcons.building_2_fill,
                () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => ListPaymentSourceView(),
                ),
              );
            }
        ),

        _settingListTile(
            context,
            '広告削除', CupertinoIcons.gift,
                () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const InAppPurchaseView(),
                ),
              );
            }),

        _settingListTile(
          context,
          'ダークモード',
          CupertinoIcons.moon_fill,
          null,
          Consumer(
            builder: (context, ref, child) {
              return CupertinoSwitch(
                activeTrackColor: CustomColors.thema,
                value: ref.watch(themeModeProvider) == AppThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggle(value);
                },
              );
            },
          ),
        ),

        _settingListTile(
            context,
            'アプリロック',
            CupertinoIcons.lock_fill,
            null,
            Consumer(
                builder: (context, ref, child) {
                  final isAppLockEnabled = ref.watch(settingProvider.select((s) => s.isAppLockEnabled));
                  return CupertinoSwitch(
                    activeTrackColor: CustomColors.thema,
                    value: isAppLockEnabled,
                    onChanged: (bool value) async {
                      final viewModel = ref.read(settingProvider.notifier);
                      if (value) {
                        // 結果を受け取りハンドリング
                        final result = await showCupertinoModalPopup<bool>(
                          context: context,
                          builder: (_) => const AppLockSettingView(),
                        );

                        if (result == true) {
                          viewModel.setAppLockEnabled(true);
                        }
                      } else {
                        // 状態を更新
                        viewModel.setAppLockEnabled(value);
                        // OFFにされたらパスワードをリセット
                        viewModel.resetPassword();
                      }
                    },
                  );
                }
            )
        ),
      ],
    );
  }

  Widget _myMenuSection(BuildContext context) {
    return  CupertinoListSection.insetGrouped(
      header: const CustomText(text: 'マイメニュー'),
      backgroundColor: CustomColors.foundation(context),
      children: [

        Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(authControllerProvider);
            if (state.isLogin) {
              return Column(
                children: [
                  _settingListTile(
                      context,
                      'アカウント情報',
                      CupertinoIcons.person_crop_rectangle,
                          () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => const UserInfoScreen(),
                              ),
                            );
                      }
                  ),
                  _settingListTile(
                      context,
                      'ログアウト',
                      CupertinoIcons.person_badge_minus_fill,
                          () {
                        _showConfirmLogoutDialog(context, ref);
                      }
                  ),
                  _settingListTile(
                      context,
                      'アカウントを削除する',
                      CupertinoIcons.delete_right_fill,
                          () {
                        _showConfirmWithdrawalDialog(context, ref);
                      }
                  )
                ],
              );
            } else {
              return _settingListTile(
                  context,
                  'ログイン・アカウント作成',
                  CupertinoIcons.person_add_solid,
                      () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
              );
            }
          },
        ),
      ],
    );
  }

  Widget _linkSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: const CustomText(text: 'LINK'),
      backgroundColor: CustomColors.foundation(context),
      footer: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CustomText(
          text: '・アプリに不具合がございましたら「アプリの不具合はこちら」よりお問い合わせください。',
          textSize: TextSize.S,
          fontWeight: FontWeight.bold,
          maxLines: 2,
        ),
      ),
      children: [

        if (Platform.isIOS)
          _settingListTile(
            context,
            'アプリをレビューする',
            CupertinoIcons.hand_thumbsup,
                () {
              _launchURL(_StaticUrl.storeRequestReview);
            },
          ),

        _settingListTile(
            context,
            'アプリの不具合はこちら',
            CupertinoIcons.paperplane,
                () {
              _openWebView(context, _StaticUrl.contact);
            }
        ),

        _settingListTile(
          context,
          '利用規約とプライバシーポリシー',
          CupertinoIcons.calendar,
              () {
            _openWebView(context, _StaticUrl.termsOfService);
          },
        ),
      ],
    );
  }

  Future<void> _showConfirmLogoutDialog(
      BuildContext context,
      WidgetRef ref
      ) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('確認'),
          content: const Text('本当にログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('キャンセル'),
            ),

            TextButton(
              onPressed: () async {
                final viewModel = ref.read(settingProvider.notifier);
                final result = await viewModel.logout();
                if (result) {
                  Navigator.of(dialogContext).pop();
                  _showSuccessDialog(context, 'ログアウトしました。');
                }

              },
              child: const CustomText(
                text: 'ログアウト',
                fontWeight: FontWeight.bold,
                color: CustomColors.negative,
                textSize: TextSize.MS,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmWithdrawalDialog(
      BuildContext context,
      WidgetRef ref
      ) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('確認'),
          content: const Text('アカウントを削除しても、アプリ内のデータは消失しませんが、バックアップ機能は無効になります。\n本当にアカウント削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('キャンセル'),
            ),

            TextButton(
              onPressed: () async {
                final viewModel = ref.read(settingProvider.notifier);
                viewModel.withdrawal();
                final result = await viewModel.withdrawal();
                if (result) {
                  Navigator.of(dialogContext).pop();
                  _showSuccessDialog(context, 'アカウントを削除しました。');
                }
              },
              child: const CustomText(
                text: '削除する',
                fontWeight: FontWeight.bold,
                color: CustomColors.negative,
                textSize: TextSize.MS,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(
      BuildContext context,
      String content
      ) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('成功'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  /// 設定リスト行UI
  Widget _settingListTile(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback? action, [
        Widget trailing = const CupertinoListTileChevron(),
      ]) {
    return CupertinoListTile(
      padding: const EdgeInsets.all(15),
      backgroundColor: CustomColors.background(context),
      title: CustomText(
        text: title,
        textSize: TextSize.MS,
        fontWeight: FontWeight.bold,
      ),
      leading: Icon(icon, color: CustomColors.thema),
      trailing: trailing,
      onTap: () {
        if (action != null) action();
      },
    );
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
}