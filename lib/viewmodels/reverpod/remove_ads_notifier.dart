
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/repository/shared_prefs_repository.dart';

final removeAdsProvider =
StateNotifierProvider<RemoveAdsNotifier, bool>((ref) {
  return RemoveAdsNotifier();
});


class RemoveAdsNotifier extends StateNotifier<bool> {
  RemoveAdsNotifier() : super(false) {
    _load();
  }

  /// SharedPreferences から読み込み
  Future<void> _load() async {
    final removeAds = SharedPreferencesService().fetchRemoveAds();
    state = removeAds;
  }

  /// removeAds を更新し永続化
  Future<void> update(bool value) async {
    state = value;
    SharedPreferencesService().saveRemoveAds(value);
  }
}
