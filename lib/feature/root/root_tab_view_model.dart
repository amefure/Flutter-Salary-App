import 'package:salary/core/repository/shared_prefs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/root/root_tab_state.dart';

final rootTabProvider = StateNotifierProvider<RootTabViewModel, RootTabState>((ref) {
  return RootTabViewModel();
});


class RootTabViewModel extends StateNotifier<RootTabState> {

  RootTabViewModel() : super(const RootTabState()) {
    _fetchHasShown();
  }

  void _fetchHasShown() {
    /// プレミアムプラン紹介ポップアップを表示済みか取得
    final hasShownPremiumIntro = SharedPreferencesService().fetchHasShownPremiumIntro();
    /// プレミアムタブを表示済みか取得
    final hasShownPremiumTab = SharedPreferencesService().fetchHasShownPremiumTab();
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
    await SharedPreferencesService().saveHasShownPremiumIntro(true);
    state = state.copyWith(
        shouldShowPremiumIntro: false,
    );
  }

  /// 表示済みに更新
  Future<void> markAsShownPremiumTab() async {
    await SharedPreferencesService().saveHasShownPremiumTab(true);
    state = state.copyWith(
      shouldShowPremiumTabBadge: false,
    );
  }
}