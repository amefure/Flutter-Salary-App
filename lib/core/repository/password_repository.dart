import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/data_source/secure_storage_data_source.dart';

final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  final dataSource = ref.watch(secureStorageDataSourceProvider);
  return PasswordRepository(dataSource);
});

class PasswordRepository {
  final ISecureStorageDataSource _dataSource;
  static const _keyPassword = 'app_lock_password';

  PasswordRepository(this._dataSource);

  Future<void> removePassword() async => await _dataSource.delete(_keyPassword);

  Future<void> setPassword(String password) async =>
      await _dataSource.write(_keyPassword, password);

  Future<String?> getPassword() async => await _dataSource.read(_keyPassword);

  Future<bool> isLockEnabled() async {
    final password = await _dataSource.read(_keyPassword);
    return password != null && password.isNotEmpty;
  }
}