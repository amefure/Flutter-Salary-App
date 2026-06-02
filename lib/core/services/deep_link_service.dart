import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepLinkInitializer {
  final _appLinks = AppLinks();

  void init(Function(Uri) onLinkOpened) async {
    /// アプリが完全に終了している状態から起動した場合
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      onLinkOpened(initialLink);
    }

    /// アプリがバックグラウンドにいる状態でタップされた場合
    _appLinks.uriLinkStream.listen((Uri uri) {
      onLinkOpened(uri);
    });
  }
}

/// ディープリンクの遷移先
enum DeepLinkDestination {
  none(''),
  registerAccount('/register');

  const DeepLinkDestination(this.path);
  final String path;

  /// 受信したUriから、一致するDestinationを安全に返す静的メソッド
  static DeepLinkDestination fromUri(Uri uri) {
    // パス（/register）またはホスト（register）が一致するものを探す
    return DeepLinkDestination.values.firstWhere(
          (destination) =>
      destination != DeepLinkDestination.none &&
          (uri.path == destination.path || uri.host == destination.path.replaceFirst('/', '')),
      orElse: () => DeepLinkDestination.none,
    );
  }
}

/// ディープリンクの宛先を管理するNotifier
class DeepLinkNotifier extends Notifier<DeepLinkDestination> {
  @override
  DeepLinkDestination build() => DeepLinkDestination.none;

  void navigateTo(DeepLinkDestination destination) {
    state = destination;
  }

  void clear() {
    state = DeepLinkDestination.none;
  }
}

final deepLinkProvider = NotifierProvider<DeepLinkNotifier, DeepLinkDestination>(
      () => DeepLinkNotifier(),
);