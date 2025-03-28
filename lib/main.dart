import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary/repository/realm_repository.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/root_tab_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// アプリのルート
void main() {
  final _repository = RealmRepository();
  // SalaryViewModelをProviderとしてセットする
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalaryViewModel(_repository)),
      ],
      child: MyApp(),
    ),
  );
}

/// アプリのルートWidget
/// テーマ用
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // IOS デザインアプリ
    return CupertinoApp(
      title: '給料MEMO App',
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
        primaryColor: CustomColors.thema,
        // Scaffoldの背景色を白に設定
        scaffoldBackgroundColor: Colors.white,
        // タブバー
        barBackgroundColor: Colors.white,
      ),
      home: RootTabViewView(),
    );
  }
}
