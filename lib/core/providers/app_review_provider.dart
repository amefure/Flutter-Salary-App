import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:salary/core/repository/user_settings_repository.dart';

final appReviewServiceProvider = Provider((ref) {
  final userSettings = ref.watch(userSettingsProvider);
  return AppReviewService(userSettings);
});

class AppReviewService {
  final UserSettingsRepository _userSettings;
  final InAppReview _inAppReview = InAppReview.instance;

  AppReviewService(this._userSettings);

  /// 給料データが登録された際に呼び出すメソッド
  Future<void> checkAndRequestReviewOnSalaryAdded() async {
    // すでにレビューリクエスト済みの場合は何もしない
    final hasRequested = _userSettings.fetchHasRequestedReview();
    if (hasRequested) return;

    // 登録回数をカウントアップして保存
    final currentCount = _userSettings.fetchSalaryRegistrationCount();
    final nextCount = currentCount + 1;
    await _userSettings.saveSalaryRegistrationCount(nextCount);

    // 「3回目」の登録のタイミングでレビューを出す
    if (nextCount >= 3) {
      await _requestReview();
    }
  }

  /// 実際にOSのレビューポップアップを呼び出す処理
  Future<void> _requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        // 画面遷移やダイアログの閉じる処理と被らないよう少し遅延を入れるとスムーズ
        await Future.delayed(const Duration(seconds: 1));
        await _inAppReview.requestReview();

        // 一度リクエストしたらフラグを立てて二度と出さないようにする
        await _userSettings.saveHasRequestedReview(true);
      }
    } catch (_) {
      // エラー時は何もしない（アプリの動作を止めない）
    }
  }
}