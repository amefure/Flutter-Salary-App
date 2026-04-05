import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/repository/user_settings_repository.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/premium/data/public_salary_repository_impl.dart';
import 'package:salary/feature/premium/domain/public_salary_repository.dart';
import 'package:salary/feature/premium/premium_root/premium_root_view_model.dart';

final premiumFunctionStateProvider = StateNotifierProvider<PremiumFunctionStateNotifier, PremiumFunctionState>((ref) {
  final localRepository = RealmDataSource();
  final publicSalaryRepository = ref.read(publicSalaryRepositoryProvider);
  final userSettings = ref.read(userSettingsProvider);
  final vm = PremiumFunctionStateNotifier(ref, localRepository, publicSalaryRepository, userSettings);
  /// build完了後に実行
  Future.microtask(() => vm.checkRelease());
  return vm;
});

class PremiumFunctionState {
  /// 給料公開しているユーザーかどうか
  final bool isPublicData;
  /// プレミアム機能が解放されているかどうか
  final bool isPremiumFeatureUnlocked;
  /// プレムアム機能が全解放(公開しなくてもアクセス可能)されているかどうか
  final bool isPremiumFullUnlocked;
  final int publicUserCount;

  /// 機能自体の解放条件：ユーザー10人
  bool get isUnLimitedFunction => publicUserCount >= 10;
  /// アプリ内課金があること自体の表示条件：ユーザー30人
  bool get isShowInAppPurchase => publicUserCount >= 30;
  /// アプリ内課金でのプレミアム機能解放購入可能条件：ユーザー50人
  bool get isUnLimitedInAppPurchase => publicUserCount >= 50;

  PremiumFunctionState({
    this.isPublicData = false,
    this.isPremiumFeatureUnlocked = false,
    this.isPremiumFullUnlocked = false,
    this.publicUserCount = 0,
  });

  PremiumFunctionState copyWith({
    bool? isPublicData,
    bool? isPremiumFeatureUnlocked,
    bool? isPremiumFullUnlocked,
    int? publicUserCount,
  }) {
    return PremiumFunctionState(
      isPublicData: isPublicData ?? this.isPublicData,
      isPremiumFeatureUnlocked: isPremiumFeatureUnlocked ?? this.isPremiumFeatureUnlocked,
      isPremiumFullUnlocked: isPremiumFullUnlocked ?? this.isPremiumFullUnlocked,
      publicUserCount: publicUserCount ?? this.publicUserCount,
    );
  }
}

class PremiumFunctionStateNotifier extends StateNotifier<PremiumFunctionState> {

  final Ref _ref;
  final RealmDataSource _localRepository;
  final PublicSalaryRepository _publicSalaryRepository;
  final UserSettingsRepository _userSettingsRepository;

  PremiumFunctionStateNotifier(
      this._ref,
      this._localRepository,
      this._publicSalaryRepository,
      this._userSettingsRepository,
      ) : super(PremiumFunctionState()) {
    checkAllPaymentSource();
    _ref.listen<bool>(
      premiumRootProvider.select((s) => s.isRefresh),
          (previous, next) {
        if (next == true && previous != true) {
          if (!state.isUnLimitedFunction) {
            // 機能解放済みならかつロック画面ならユーザー数取得ではリフレッシュ
            _fetchUserCount();
            _ref.read(premiumRootProvider.notifier).clearIsRefresh();
          } else {
            // 機能未開放かつロック画面なら公開情報の取得をリフレッシュ
            checkAllPaymentSource();
          }
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

  void updateIsPremiumFullUnlocked(bool isPremiumFullUnlocked) {
    _userSettingsRepository.savePremiumFullUnlocked(isPremiumFullUnlocked);
    state = state.copyWith(
      isPremiumFullUnlocked: isPremiumFullUnlocked,
    );
  }

  void updateIsPremiumFeatureUnlocked(bool isPremiumFeatureUnlocked) {
    _userSettingsRepository..savePremiumFeatureUnlocked(isPremiumFeatureUnlocked);
    state = state.copyWith(
      isPremiumFeatureUnlocked: isPremiumFeatureUnlocked,
    );
  }

  Future<void> _fetchUserCount() async {
    final userCount = await _publicSalaryRepository.fetchUserCount();
    state = state.copyWith(
      publicUserCount: userCount
    );
  }

  Future<void> _fetchIsPremiumUnlocked() async {
    final isPremiumFullUnlocked = _userSettingsRepository.fetchPremiumFullUnlocked();
    final isPremiumFeatureUnlocked = _userSettingsRepository.fetchPremiumFeatureUnlocked();
    state = state.copyWith(
        /// 全機能解放がtrueなら機能もtrueにする
        isPremiumFeatureUnlocked: isPremiumFullUnlocked ? true : isPremiumFeatureUnlocked,
        isPremiumFullUnlocked: isPremiumFullUnlocked
    );
  }

  Future<void> checkRelease() async {
    await _fetchUserCount();
    _fetchIsPremiumUnlocked();
  }
}
