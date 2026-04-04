import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/overlay/global_error_overlay.dart';
import 'package:salary/core/common/overlay/global_loading_overlay.dart';
import 'package:salary/core/data_source/shared_preferences_data_source.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/providers/global_loading_provider.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/providers/theme_mode_notifier.dart';
import 'package:salary/core/repository/biometrics_service.dart';
import 'package:salary/core/repository/password_service.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/root/root_tab_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:salary/feature/app_lock/app_lock_setting_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  FirebaseAnalytics _ = FirebaseAnalytics.instance;

  // SharedPreferencesの初期化
  final prefs = await SharedPreferences.getInstance();

  final passwordService = PasswordService();

  bool isLockEnabled = await passwordService.isLockEnabled();

  runApp(
    // Riverpod用のスコープをProviderScopeで構築
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MyApp(
        startScreen:
            isLockEnabled
                ? const AppLockSettingView(isEntry: false)
                : const RootTabView(),
      ),
    ),
  );
}

/// アプリのルートWidget
/// テーマ用
class MyApp extends ConsumerWidget {
  final Widget startScreen;

  const MyApp({
    super.key,
    required this.startScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザー変更を検知したら全体をリフレッシュする
    final mode = ref.watch(themeModeProvider);
    // アプリ起動時にインスタンス化しておく(初回ユーザー取得処理)
    final _ = ref.read(authStateProvider);
    // アプリ起動時にプレミアム解放チェックAPIを実行しておく
    final _ = ref.read(premiumFunctionStateProvider);
    final brightness = switch (mode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
    };

    final loadingState = ref.watch(globalLoadingProvider);
    final errorMessage = ref.watch(globalErrorProvider);

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
        const Locale('ja', 'JP'), // 日本語
      ],
      theme: CupertinoThemeData(
        // ユーザー設定モードを反映
        brightness: brightness,
        // プライマリーカラー
        primaryColor: CustomColors.thema,
        // Scaffoldの背景色を白に設定
        scaffoldBackgroundColor: CustomColors.background(context),
        // タブバー
        // CustomColors.background(context)で指定すると色が変化しない
        // 未指定にするとMyData画面がバグる
        // => Barが不透明扱いでUIに高さが認識されなくなりスクロールに食われる
        barBackgroundColor: CupertinoColors.systemBackground,
      ),
      home: Stack(
        children: [
          startScreen,

          if (loadingState.isLoading)
            const GlobalLoadingOverlay(),

          if (errorMessage != null)
            GlobalErrorOverlay(
              message: errorMessage,
              onDismissed: () { ref.read(globalErrorProvider.notifier).clear(); },
            ),
        ],
      ),
    );
  }
}