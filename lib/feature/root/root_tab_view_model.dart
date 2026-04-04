import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/root/root_tab_state.dart';

final rootTabProvider = StateNotifierProvider<RootTabViewModel, RootTabState>((ref) {
  final userSettings = ref.read(userSettingsProvider);
  return RootTabViewModel(userSettings);
});


class RootTabViewModel extends StateNotifier<RootTabState> {

  final UserSettingsRepository _userSettingsRepository;

  RootTabViewModel(this._userSettingsRepository) : super(const RootTabState()) {
    _fetchHasShown();
  }

  void _fetchHasShown() {
    /// プレミアムプラン紹介ポップアップを表示済みか取得
    final hasShownPremiumIntro = _userSettingsRepository.fetchHasShownPremiumIntro();
    /// プレミアムタブを表示済みか取得
    final hasShownPremiumTab = _userSettingsRepository.fetchHasShownPremiumTab();
    /// StateではUIで表示すべきかどうか
    /// ポップアップ：false(未表示)であればtrue(ポップアップを表示させる)とする
    /// タブ：false(未表示)であればtrue(タブバッジを表示させる)とする
    logger('hasShownPremiumTab$hasShownPremiumTab');
    state = state.copyWith(
      shouldShowPremiumIntro: !hasShownPremiumIntro,
      shouldShowPremiumTabBadge: !hasShownPremiumTab
    );
  }

  /// 表示済みに更新
  Future<void> markAsShownPremiumIntro() async {
    await _userSettingsRepository.saveHasShownPremiumIntro(true);
    state = state.copyWith(
        shouldShowPremiumIntro: false,
    );
  }

  /// 表示済みに更新
  Future<void> markAsShownPremiumTab() async {
    await _userSettingsRepository.saveHasShownPremiumTab(true);
    state = state.copyWith(
      shouldShowPremiumTabBadge: false,
    );
  }
}