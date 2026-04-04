
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/repository/user_settings_repository.dart';

final removeAdsProvider = StateNotifierProvider<RemoveAdsNotifier, bool>((ref) {
  final userSettings = ref.read(userSettingsProvider);
  return RemoveAdsNotifier(userSettings);
});

class RemoveAdsNotifier extends StateNotifier<bool> {
  final UserSettingsRepository _userSettingsRepository;

  RemoveAdsNotifier(this._userSettingsRepository) : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = _userSettingsRepository.fetchRemoveAds();
  }

  Future<void> update(bool value) async {
    state = value;
    await _userSettingsRepository.saveRemoveAds(value);
  }
}