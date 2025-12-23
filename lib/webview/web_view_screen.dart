import 'package:flutter/cupertino.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView
class WebViewScreen extends StatefulWidget {
  // 対象URL
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          // JavaScript有効にする
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          // 初期描画対象のURLを指定
          ..loadRequest(Uri.parse(widget.url))
          // 遷移ハンドリング
          ..setNavigationDelegate(
            // ページ読み込み完了後に進む / 戻るボタンの状態を更新
            NavigationDelegate(onPageFinished: (_) => _updateNavigationState()),
          );
  }

  /// 進む / 戻るボタンの状態を更新
  Future<void> _updateNavigationState() async {
    final back = await _controller.canGoBack();
    final forward = await _controller.canGoForward();
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // 上部ナビゲーションバー
      navigationBar: CupertinoNavigationBar(
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed:
                  canGoBack
                      ? () async {
                        await _controller.goBack();
                        _updateNavigationState();
                      }
                      : null,
              child: Icon(
                CupertinoIcons.left_chevron,
                color:
                    canGoBack
                        ? CustomColors.thema
                        : CupertinoColors.inactiveGray,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed:
                  canGoForward
                      ? () async {
                        await _controller.goForward();
                        _updateNavigationState();
                      }
                      : null,
              child: Icon(
                CupertinoIcons.right_chevron,
                color:
                    canGoForward
                        ? CustomColors.thema
                        : CupertinoColors.inactiveGray,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.refresh),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
      ),
      // WebView表示エリア
      child: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
