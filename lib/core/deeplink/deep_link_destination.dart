import 'package:flutter/cupertino.dart';

@immutable
sealed class DeepLinkDestination {
  const DeepLinkDestination();

  /// ディープリンク起動先を制御
  static DeepLinkDestination fromUri(Uri uri) {
    final params = uri.queryParameters;
    return switch (uri) {
      _ when DeepLinkRegisterAccount.match(uri) => () {
        final email = params[DeepLinkRegisterAccount.parameterNames[0]];
        final signature = params[DeepLinkRegisterAccount.parameterNames[1]];
        final expires = params[DeepLinkRegisterAccount.parameterNames[2]];
        if (email != null && signature != null && expires != null) {
          final expiresInt = int.tryParse(expires) ?? 0;
          return DeepLinkRegisterAccount(email: email, signature: signature, expires: expiresInt);
        }
        return const DeepLinkNone();
      }(),

      _ => const DeepLinkNone(),
    };
  }
}

/// 遷移先なし
class DeepLinkNone extends DeepLinkDestination {
  const DeepLinkNone();
}

/// 新規登録画面
class DeepLinkRegisterAccount extends DeepLinkDestination {
  final String email;
  final String signature;
  final int expires;

  static bool match(Uri uri) {
    final cleanPath = path.replaceFirst('/', '');
    return uri.path == path || uri.host == cleanPath;
  }
  static const String path = '/register';
  static const List<String> parameterNames = ['email', 'signature', 'expires'];
  const DeepLinkRegisterAccount({
    required this.email,
    required this.signature,
    required this.expires,
  });
}