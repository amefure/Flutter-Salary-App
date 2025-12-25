# シンプル給料記録アプリ

給料や副業収益を記録・管理するためのメモアプリ

## アプリ概要

＼シンプルな給料・副業収入記録アプリ／

◇このアプリでできること

1. 給料を記録
2. 年収や手取りが把握できる
3. グラフで増減が見える化
4. 副業やバイトなどの収益も別で管理可能
5. アプリにロックもかけられる(生体認証(指紋/顔)でログイン)

追加して欲しい機能や改善してほしい箇所がありましたら気軽にレビューから教えてください！

## 開発環境
- Android Studio：Otter 2 Feature Drop
- Xcode：26.0.1 
- Flutter：3.38.3
- Dart：3.10.1
- FVM：4.0.5
- Mac M1：Sequoia 15.6.1

## ディレクトリ構成
※ Feature-Firstに変更ずみ

以下旧(TODO：更新)
```
(root)
 ∟ android ・・・Android用のネイティブコードや設定
 ∟ ios     ・・・iOS用のネイティブコードや設定
 ∟ assets  ・・・リソース(画像etc...)
 ∟ lib
     ∟ model        ・・・Relam Database Model & 自動生成ファイル
     ∟ repository   ・・・Realm / Shread Preferences / 生体認証リポジトリ
     ∟ utilities     ・・・日付 / カラー / 数値 etc...
     ∟ viewmodels   ・・・Realm Saraly ViewModel
     ∟ views        ・・・View
         ∟ components ・・・UIコンポーネント
         ∟ domain     ・・・ドメイン機能
         ∟ setting    ・・・設定画面
         ∟ weview     ・・・WebView
         ∟ root_tab_view.dart ・・・アプリタブ管理ビュー
     ∟ firebase_options.dart  ・・・Firebaesの設定ファイル(自動生成)
     ∟ main.dart    ・・・アプリのエントリーポイント
 ∟ pubspec.yaml     ・・・プロジェクト/パッケージ設定管理ファイル
 ∟ README.md
 ∟ (etc)
```

# ライブラリ

## Analytics

- **[firebase_analytics](https://pub.dev/packages/firebase_analytics) (11.5.0)** - Firebase Analytics データ解析

## InAppPurchase
- **[in_app_purchase](https://pub.dev/packages/in_app_purchase) (3.2.3)** - アプリ内課金のOS機能ラッパー

## Utility
- **[url_launcher](https://pub.dev/packages/url_launcher) (6.3.1)** - URL の起動（外部ブラウザ、電話、メールなど）
- **[intl](https://pub.dev/packages/intl) (0.19.0)** - 日付・数値・通貨のフォーマット処理 

## Storage
- **[shared_preferences](https://pub.dev/packages/shared_preferences) (2.5.2)** - 永続的なデータ保存（ローカルストレージ）
- **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (9.2.4)** - 暗号化されたデータの保存
- **[realm](https://pub.dev/packages/realm) (20.0.1)** - Realm DataBase

## UI
- **[fl_chart](https://pub.dev/packages/fl_chart) (0.70.2)** - グラフ描画
- **[webview_flutter](https://pub.dev/packages/webview_flutter) (4.10.0)** - WebView

## Service
- **[provider](https://pub.dev/packages/provider) (6.1.2)** - ~~状態管理(old)~~
- **[riverpod](https://pub.dev/packages/riverpod) (2.6.1)** - 状態管理
- **[local_auth](https://pub.dev/packages/local_auth) (2.3.0)** - 生体認証
- **[firebase_core](https://pub.dev/packages/firebase_core) (3.13.0)** - Firebase のコアライブラリ
- **[google_mobile_ads](https://pub.dev/packages/google_mobile_ads) (5.3.1)** - Google AdMob

## Develop
- **[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) (0.14.3)** - アプリアイコンの設定
- **[change_app_package_name](https://github.com/atiqsamtia/change_app_package_name) (1.1.0)** - アプリID(BundleID)の管理
- **[flutter_lints](https://pub.dev/packages/flutter_lints) (6.0.0)** - 静的解析ツール