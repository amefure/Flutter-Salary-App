import 'package:salary/core/repository/shared_prefs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final rootTabProvider = StateNotifierProvider<RootTabViewModel, bool>((ref) {
  return RootTabViewModel();
});

class RootTabViewModel extends StateNotifier<bool> {

  RootTabViewModel() : super(SharedPreferencesService().fetchHasShownPremiumIntro());

  /// 表示済みに更新する
  Future<void> markAsShown() async {
    await SharedPreferencesService().saveHasShownPremiumIntro(true);
    state = false;
  }
}