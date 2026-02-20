import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/core/repository/shared_prefs_repository.dart';

final premiumFunctionStateProvider = StateNotifierProvider<PremiumFunctionStateNotifier, PremiumFunctionState>((ref) {
  final repository = RealmRepository();
  return PremiumFunctionStateNotifier(ref, repository);
});

class PremiumFunctionState {
  final bool isPublicData;
  final bool isSubscribed;

  PremiumFunctionState({
    this.isPublicData = false,
    this.isSubscribed = true,
  });

  PremiumFunctionState copyWith({
    bool? isPublicData,
    bool? isSubscribed,
  }) {
    return PremiumFunctionState(
        isPublicData: isPublicData ?? this.isPublicData,
        isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}

class PremiumFunctionStateNotifier extends StateNotifier<PremiumFunctionState> {

  final Ref ref;
  final RealmRepository _repository;

  PremiumFunctionStateNotifier(this.ref, this._repository) : super(PremiumFunctionState()) {
    checkAllPaymentSource();
  }

  void checkAllPaymentSource() {
    final sources = _repository.fetchAll<PaymentSource>();

    final hasPublicSource = sources.any((source) => source.isPublic);

    state = state.copyWith(
      isPublicData: hasPublicSource,
    );
  }
}
