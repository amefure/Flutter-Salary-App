import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:salary/core/utils/logger.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

class TokenStorage {
  // ★ テストからモックを注入できるようにコンストラクタを追加
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  Future<void> save(String token) async {
    logger('======= Tokenを保存しました =======');
    await _storage.write(key: _key, value: token);
  }

  Future<String?> read() async {
    return _storage.read(key: _key);
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}