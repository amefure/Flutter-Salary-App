import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordService {
  final _storage = FlutterSecureStorage();
  static const _keyPassword = "app_lock_password";

  Future<void> removePassword() async {
    await _storage.delete(key: _keyPassword);
  }

  Future<void> setPassword(String password) async {
    await _storage.write(key: _keyPassword, value: password);
  }

  Future<String?> getPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  Future<bool> isLockEnabled() async {
    String? value = await _storage.read(key: _keyPassword);
    return value?.isNotEmpty ?? false;
  }
}
