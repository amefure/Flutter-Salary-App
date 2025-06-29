import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:salary/repository/biometrics_service.dart';
import 'package:salary/repository/password_service.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/views/root_tab_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:salary/views/setting/app_lock_setting_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// ⌘ + option + L => フォーマット
/// アプリのエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AdMob初期化
  MobileAds.instance.initialize();
  // 生体認証有効チェック
  BiometricsService().checkAvailability();
  // Firebase初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseAnalyticsのインスタンスを作成
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final passwordService = PasswordService();

  bool isLockEnabled = await passwordService.isLockEnabled();

  runApp(
    // Riverpod用のスコープをProviderScopeで構築
    ProviderScope(
      child: MyApp(
        startScreen:
            isLockEnabled
                ? AppLockSettingView(isEntry: false)
                : RootTabViewView(),
      ),
    ),
  );
}

/// アプリのルートWidget
/// テーマ用
class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    // IOS デザインアプリ
    return CupertinoApp(
      title: 'シンプル給料記録',
      // デバッグタグを非表示
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        // マテリアル Widget(Android)
        GlobalMaterialLocalizations.delegate,
        // 共通 Widget
        GlobalWidgetsLocalizations.delegate,
        // クパチーノ Widget(iOS)
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ja', 'JP'), // 日本語
      ],
      theme: CupertinoThemeData(
        // ライトモード限定にする
        brightness: Brightness.light,
        // プライマリーカラー
        primaryColor: CustomColors.thema,
        // Scaffoldの背景色を白に設定
        scaffoldBackgroundColor: Colors.white,
        // タブバー
        barBackgroundColor: Colors.white,
      ),
      home: startScreen,
    );
  }
}