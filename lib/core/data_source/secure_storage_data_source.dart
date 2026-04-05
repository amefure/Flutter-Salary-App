import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageDataSourceProvider = Provider<ISecureStorageDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureStorageDataSource(storage);
});


abstract class ISecureStorageDataSource {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class SecureStorageDataSource implements ISecureStorageDataSource {
  final FlutterSecureStorage _storage;
  SecureStorageDataSource(this._storage);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}