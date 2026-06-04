import 'package:app_links/app_links.dart';
import 'package:salary/core/deeplink/deep_link_destination.dart';

class DeepLinkInitializer {
  final _appLinks = AppLinks();

  void init(Function(DeepLinkDestination) onDestinationParsed) async {
    /// URIから遷移クラスにパース
    void parseAndNotify(Uri uri) {
      final destination = DeepLinkDestination.fromUri(uri);
      onDestinationParsed(destination);
    }
    /// アプリが完全に終了している状態から起動した場合
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      parseAndNotify(initialLink);
    }

    /// アプリがバックグラウンドにいる状態でタップされた場合
    _appLinks.uriLinkStream.listen((Uri uri) {
      parseAndNotify(uri);
    });
  }
}
