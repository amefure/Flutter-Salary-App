import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/feature/premium/premium_root/premium_root_state.dart';

final premiumRootProvider = StateNotifierProvider.autoDispose<PremiumRootViewModel, PremiumRootState>((ref) {
  return PremiumRootViewModel();
});

class PremiumRootViewModel extends StateNotifier<PremiumRootState> {

  PremiumRootViewModel(): super(PremiumRootState.initial());

  void updateTab(PremiumTab tab) {
    state = state.copyWith(
      currentTab: tab
    );
  }

  void refresh() {
    state = state.copyWith(
        isRefresh: true
    );
  }
  void clearIsRefresh() {
    state = state.copyWith(
        isRefresh: false
    );
  }
}