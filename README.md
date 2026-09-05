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
6. 毎月の給料日を自動でお知らせする「給料日リマインダー機能」
7. 同年代や同業種の年収や給料を閲覧可能(年収TOP10や年収層なども確認)
   ※ 給料データが勝手に公開されることはないのでご安心ください

追加して欲しい機能や改善してほしい箇所がありましたら気軽にレビューから教えてください！

## 開発環境
- Android Studio Quail 2 | 2026.1.2
- Xcode：26.3
- Flutter：3.38.3(stable)
- Dart：3.10.1
- FVM：4.0.5
- Mac M1：Tahoe 26.2

## ディレクトリ構成

- 「Feature-First」構成
- Featureは別のFeatureに依存しないようにしています

```text
(root)
 ∟ android ・・・Android用のネイティブコードや設定
 ∟ ios     ・・・iOS用のネイティブコードや設定
 ∟ assets  ・・・リソース(画像/アイコン/Lottieファイル)
 ∟ lib
     ∟ core ・・・アプリ全体で利用する共通基盤
           ∟ api         ・・・APIクライアント、APIException、認証トークンストレージ
           ∟ auth        ・・・認証周りの状態管理
           ∟ common      ・・・全体共通のコンポーネント、オーバーレイ(ダイアログ等)
           ∟ config      ・・・各種設定定義
           ∟ data_source ・・・データソース
           ∟ deeplink    ・・・ディープリンク
           ∟ mock        ・・・デバッグ環境用モック
           ∟ models      ・・・Realmのデータモデル定義
           ∟ notify       ・・・ローカル通知等
           ∟ provider    ・・・汎用的な状態管理
           ∟ repository  ・・・データ操作の実態(Realm / Firebase / SharedPreferences)
           ∟ utils       ・・・日付 / カラー / 数値 / ロガー等の汎用ツール
     ∟ feature ・・・各画面ごとの機能実装
           ∟ analytics        ・・・解析機能(プレミアム)
           ∟ app_lock         ・・・アプリロック機能
           ∟ auth             ・・・認証系
           ∟ charts           ・・・グラフ機能(MyData)
           ∟ in_app_purchase  ・・・アプリ内課金
           ∟ payment_source   ・・・支払い元管理
           ∟ premium          ・・・プレミアム機能(ロック画面 / タイムライン / サマリー)
           ∟ public_salary    ・・・給料公開機能           
           ∟ reminder         ・・・給料日リマインダー設定・通知管理機能
           ∟ root             ・・・ルートタブ機能
           ∟ salary           ・・・給料一覧(list / MyHistory) / 給料詳細(detail) / 入力(input)
           ∟ settings         ・・・設定画面 / プレミアム機能解放
           ∟ webview          ・・・WebView
     ∟ firebase_options.dart ・・・Firebaseの設定ファイル(自動生成)
     ∟ main.dart    ・・・アプリのエントリーポイント(ProviderScopeの設定)
 ∟ pubspec.yaml     ・・・プロジェクト/パッケージ設定管理ファイル
 ∟ test
     ∟ core ・・・各ファイルのテストコード
     ∟ feature ・・・各ファイルのテストコード
 ∟ README.md
 ∟ (etc)
```

## 環境構築

FVMを使用してFlutter SDKを管理しています。

```bash
# 1.FVM自体のインストール
$ brew tap leoafarias/fvm
$ brew install fvm

# 2.プロジェクトルートでfvm installコマンドの実行
$ fvm install
```

## テストコード
テストコードは以下を対象として実装中

coverage：52.2 %(現在)

- Repository
- ViewModel
- Utility

```
# 1.テストコードの実行 & カバレッジレポート作成
$ fvm flutter test --coverage       
# 2.htmlに出力
$ genhtml coverage/lcov.info -o coverage/html
# 3.テスト対象外のディレクトリを除外
$ fvm flutter pub run remove_from_coverage:remove_from_coverage -f coverage/lcov.info -r 'core/mock/'
# 4.カバレッジレポートを表示
$ open coverage/html/index.html        
```

## ディープリンク(Scheme)

▼ Scheme：salary
```
/// アプリ起動
/// 認証エラー(403)WebページからのアプリBack
$ salary://

/// 新規会員登録
$ salary://register
```

# ライブラリ

## Analytics
- **[firebase_analytics](https://pub.dev/packages/firebase_analytics) (11.5.0)** - Firebase Analytics データ解析

## InAppPurchase
- **[in_app_purchase](https://pub.dev/packages/in_app_purchase)** - アプリ内課金のOS機能ラッパー

## Notification & Permission
- **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) (17.2.4)** - ローカルプッシュ通知の実装
- **[timezone](https://pub.dev/packages/timezone) (0.9.4)** - タイムゾーンを考慮した日時スケジュール通知
- **[permission_handler](https://pub.dev/packages/permission_handler) (11.4.0)** - 端末の権限管理（通知許可チェック等）

## Utility
- **[url_launcher](https://pub.dev/packages/url_launcher) (6.3.1)** - URL の起動（外部ブラウザ、電話、メールなど）
- **[intl](https://pub.dev/packages/intl) (0.20.2)** - 日付・数値・通貨のフォーマット処理
- **[connectivity_plus](https://pub.dev/packages/connectivity_plus) (6.1.5)** - ネットワーク環境
- **[app_links](https://pub.dev/packages/app_links) (7.0.0)** - ディープリンク
- **[package_info_plus](https://pub.dev/packages/package_info_plus) (9.0.1)** - パッケージ情報取得
- **[in_app_review](https://pub.dev/packages/in_app_review) (2.0.12)** - アプリレビュー機能

## Storage
- **[shared_preferences](https://pub.dev/packages/shared_preferences) (2.5.2)** - 永続的なデータ保存（ローカルストレージ / リマインダー設定等）
- **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (9.2.4)** - 暗号化されたデータの保存
- **[realm](https://pub.dev/packages/realm) (20.0.1)** - Realm DataBase

## UI
- **[fl_chart](https://pub.dev/packages/fl_chart) (0.70.2)** - グラフ描画
- **[syncfusion_flutter_charts](https://pub.dev/packages/syncfusion_flutter_charts) (32.2.7)** - グラフ描画(横向き)
- **[webview_flutter](https://pub.dev/packages/webview_flutter) (4.10.0)** - WebView

## Service
- **[provider](https://pub.dev/packages/provider) (6.1.2)** - ~~状態管理(old)~~
- **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod) (2.6.1)** - 状態管理
- **[local_auth](https://pub.dev/packages/local_auth) (2.3.0)** - 生体認証
- **[firebase_core](https://pub.dev/packages/firebase_core) (3.14.0)** - Firebase のコアライブラリ
- **[google_mobile_ads](https://pub.dev/packages/google_mobile_ads) (5.3.1)** - Google AdMob

## Develop
- **[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) (0.14.3)** - アプリアイコンの設定
- **[change_app_package_name](https://github.com/atiqsamtia/change_app_package_name) (1.1.0)** - アプリID(BundleID)の管理
- **[flutter_lints](https://pub.dev/packages/flutter_lints) (6.0.0)** - 静的解析ツール
- **[mocktail](https://pub.dev/packages/mocktail) (1.0.4)** - テストモックツール
- **[remove_from_coverage](https://pub.dev/packages/remove_from_coverage) (2.0.0)** - カバレッジレポート除外ツール