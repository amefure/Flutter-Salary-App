import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsService {
  /// シングルトンインスタンスを保持するための static フィールド
  static final BiometricsService _instance = BiometricsService._internal();
  /// プライベートなNamed Constructors
  /// _を付与しているのでprivateアクセスになる
  BiometricsService._internal();
  /// factory コンストラクタでシングルトンを提供
  factory BiometricsService() => _instance;

  /// 生体認証機能操作基底クラス
  final LocalAuthentication _auth = LocalAuthentication();
  /// 生体認証が利用可能かどうか
  bool isAvailable = false;

  /// 生体認証のチェック（内部用）
  /// アプリルートで呼び出す
  Future<void> checkAvailability() async {
    // 端末が生体認証機能を搭載しているかどうか
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    // 端末が生体認証機能をサポートしているかどうか
    final isDeviceSupported = await _auth.isDeviceSupported();
    isAvailable = (canCheckBiometrics && isDeviceSupported);

    debugPrint("Biometrics Available: $isAvailable");
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!isAvailable) {
      debugPrint("生体認証は使用できません");
      return false;
    }

    try {
      return await _auth.authenticate(
        localizedReason: '生体認証を利用してアプリにログインできます。',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint("生体認証エラー: $e");
      return false;
    }
  }
}
