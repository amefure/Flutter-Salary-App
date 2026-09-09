import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:salary/core/repository/user_settings_repository.dart';

final appReviewServiceProvider = Provider((ref) {
  return AppReviewService(ref);
});

class AppReviewService {
  final Ref _ref;
  final InAppReview _inAppReview = InAppReview.instance;

  AppReviewService(this._ref);

  /// 給料データが登録された際に呼び出すメソッド
  Future<void> checkAndRequestReviewOnSalaryAdded() async {
    final userSettings = _ref.read(userSettingsProvider);

    // すでにレビューリクエスト済みの場合は何もしない
    final hasRequested = userSettings.fetchHasRequestedReview();
    if (hasRequested) return;

    // 登録回数をカウントアップして保存
    final currentCount = userSettings.fetchSalaryRegistrationCount();
    final nextCount = currentCount + 1;
    await userSettings.saveSalaryRegistrationCount(nextCount);

    // 「3回目」の登録のタイミングでレビューを出す
    if (nextCount >= 3) {
      // 画面が閉じられるアニメーションや処理と完全に競合しないよう、十分な遅延を入れる
      Future.delayed(const Duration(seconds: 2), () async {
        await _requestReview(userSettings);
      });
    }
  }

  Future<void> _requestReview(UserSettingsRepository userSettings) async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await userSettings.saveHasRequestedReview(true);
      }
    } catch (_) {
      // エラー時は何もしない
    }
  }
}