import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView
class WebViewScreen extends StatefulWidget {
  // 対象URL
  final String url;
  // タイトル
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: () {
            // リロード機能
            _controller.reload(); 
          },
        ),
      ),
      child: WebViewWidget(controller: _controller),
    );
  }
}
