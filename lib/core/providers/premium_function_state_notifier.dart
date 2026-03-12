import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/core/repository/shared_prefs_repository.dart';
import 'package:salary/feature/premium/data/public_salary_repository_impl.dart';
import 'package:salary/feature/premium/domain/public_salary_repository.dart';
import 'package:salary/feature/premium/premium_root/premium_root_view_model.dart';

final premiumFunctionStateProvider = StateNotifierProvider<PremiumFunctionStateNotifier, PremiumFunctionState>((ref) {
  final localRepository = RealmRepository();
  final publicSalaryRepository = ref.read(publicSalaryRepositoryProvider);
  final vm = PremiumFunctionStateNotifier(ref, localRepository, publicSalaryRepository);
  /// build完了後に実行
  Future.microtask(() => vm.fetchUserCount());
  return vm;
});

class PremiumFunctionState {
  final bool isPublicData;
  final bool isSubscribed;
  final int publicUserCount;

  bool get isUnLimitedFunction => publicUserCount >= 1;

  PremiumFunctionState({
    this.isPublicData = false,
    this.isSubscribed = true,
    this.publicUserCount = 0,
  });

  PremiumFunctionState copyWith({
    bool? isPublicData,
    bool? isSubscribed,
    int? publicUserCount,
  }) {
    return PremiumFunctionState(
      isPublicData: isPublicData ?? this.isPublicData,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      publicUserCount: publicUserCount ?? this.publicUserCount,
    );
  }
}

class PremiumFunctionStateNotifier extends StateNotifier<PremiumFunctionState> {

  final Ref _ref;
  final RealmRepository _localRepository;
  final PublicSalaryRepository _publicSalaryRepository;

  PremiumFunctionStateNotifier(
      this._ref,
      this._localRepository,
      this._publicSalaryRepository
      ) : super(PremiumFunctionState()) {
    checkAllPaymentSource();
    _ref.listen<bool>(
      premiumRootProvider.select((s) => s.isRefresh),
          (previous, next) {
        // リフレッシュ対象は機能が開放されていない場合のみ
        if (next == true && previous != true && !state.isUnLimitedFunction) {
          fetchUserCount();
          _ref.read(premiumRootProvider.notifier).clearIsRefresh();
        }
      },
    );
  }

  void checkAllPaymentSource() {
    final sources = _localRepository.fetchAll<PaymentSource>();

    final hasPublicSource = sources.any((source) => source.isPublic);

    state = state.copyWith(
      isPublicData: hasPublicSource,
    );
  }

  Future<void> fetchUserCount() async {
    final userCount = await _publicSalaryRepository.fetchUserCount();
    state = state.copyWith(
      publicUserCount: userCount
    );
  }
}
