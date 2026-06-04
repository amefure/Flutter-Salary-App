import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/deeplink/deep_link_destination.dart';

/// ディープリンクの宛先を管理するNotifier
class DeepLinkNotifier extends Notifier<DeepLinkDestination> {
  @override
  DeepLinkDestination build() => const DeepLinkNone();

  void navigateTo(DeepLinkDestination destination) {
    state = destination;
  }

  void clear() {
    state = const DeepLinkNone();
  }
}

final deepLinkProvider = NotifierProvider<DeepLinkNotifier, DeepLinkDestination>(
      () => DeepLinkNotifier(),
);