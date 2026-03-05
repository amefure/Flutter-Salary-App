import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/api_exception.dart';
import 'package:salary/core/auth/auth_state.dart';
import 'package:salary/core/config/public_policy_config.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/realm_repository.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/auth/data/auth_repository_impl.dart';
import 'package:salary/feature/auth/domain/auth_repository.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/feature/payment_source/data/payment_repository_impl.dart';
import 'package:salary/feature/payment_source/domain/payment_repository.dart';
import 'package:salary/feature/salary/data/salary_repository_impl.dart';
import 'package:salary/feature/salary/domain/salary_repository.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final repository = RealmRepository();
  final salaryRepository = ref.read(salaryRepositoryProvider);
  final paymentRepository = ref.read(paymentRepositoryProvider);
  return AuthStateNotifier(ref, authRepository, repository, salaryRepository, paymentRepository);
  },
);

class AuthStateNotifier extends StateNotifier<AuthState> {

  AuthStateNotifier(
      this._ref,
      this._authRepository,
      this._realmRepository,
      this._salaryRepository,
      this._paymentRepository
      ) : super(const AuthState()) {
    // 初回インスタンス化時にユーザー情報を取得する
    _fetchAndSetUpUser();
  }

  final Ref _ref;
  final AuthRepository _authRepository;
  final RealmRepository _realmRepository;
  final SalaryRepository _salaryRepository;
  final PaymentRepository _paymentRepository;

  /// 新規登録
  Future<void> registerAccount({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String region,
    required DateTime birthday,
    required String job,
    required String jobCategory,
}) async {
    final user = await _authRepository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      region: region,
      birthday: birthday,
      job: job,
      jobCategory: jobCategory
    );
    // ローカルデータを他ユーザーのデータを削除
    _deleteOtherData(user.id);
    // クラウドデータの同期
    await _syncCloudToLocalData();
    state = state.copyWith(user);
  }

  /// ログイン
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.login(
      email: email,
      password: password,
    );
    // ローカルデータを他ユーザーのデータを削除
    _deleteOtherData(user.id);
    // クラウドデータの同期
    await _syncCloudToLocalData();
    state = state.copyWith(user);
  }

  /// ローカルデータを他ユーザーのデータを削除
  void _deleteOtherData(int userId) {
    final allSalaries = _realmRepository.fetchAll<Salary>();
    final allPaymentSources = _realmRepository.fetchAll<PaymentSource>();

    /// ログインユーザーIDと異なる支払い元を抽出(nullは対象外)
    final targetSourceIds = allPaymentSources
        .where((source) => source.publicUserId != null && source.publicUserId != userId)
        .map((source) => source.id)
        .toList();

    /// 対象の支払い元の給料データを算出
    final targetSalaries = allSalaries
        .where((salary) => targetSourceIds.contains(salary.source?.id))
        .toList();
    if (targetSourceIds.isNotEmpty || targetSalaries.isNotEmpty) {
      /// 支払い元と給料情報を削除する
      _realmRepository.deleteByIds<PaymentSource>(targetSourceIds);
      _realmRepository.deleteByIds<Salary>(targetSalaries.map((s) => s.id));
      // MyData画面のリフレッシュ
      _ref.read(chartSalaryProvider.notifier).refresh();
      // Homeリスト画面のリフレッシュ
      _ref.read(listSalaryProvider.notifier).refresh();
    }
  }

  Future<void> _syncCloudToLocalData() async {
    try {
      final cloudSources = await _paymentRepository.fetchAllUserList();
      final cloudSalaries = await _salaryRepository.fetchAllUserList();
      if (cloudSources.isEmpty && cloudSalaries.isEmpty) return;

      _realmRepository.addAll<PaymentSource>(cloudSources);
      _realmRepository.addAll<Salary>(cloudSalaries);

      logger('同期完了: PaymentSource：${cloudSources.length}件');
      logger('同期完了: Salary：${cloudSalaries.length}件');
      // MyData画面のリフレッシュ
      _ref.read(chartSalaryProvider.notifier).refresh();
      // Homeリスト画面のリフレッシュ
      _ref.read(listSalaryProvider.notifier).refresh();
    } catch (e) {
      logger('同期エラー: $e');
    }
  }

  /// ユーザー情報取得 & State更新
  Future<void> _fetchAndSetUpUser({
    bool isForce = false
  }) async {
    // すでにログイン済みなら取得しない && 強制取得かどうか
    if (state.isLogin && !isForce) { return; }
    // ローカルからキャッシュユーザーを取得
    final cachedUser = await _authRepository.getCachedUser();
    if (cachedUser != null) {
      state = state.copyWith(cachedUser);
    }
    // 時間のかかるAPIは後から取得する
    try {
      final freshUser = await _authRepository.fetchUserFromApi();
      state = state.copyWith(freshUser);
    } on ApiException catch (e) {
      // 認証エラーならログアウト処理
      if (e.type == ApiErrorType.unauthorized) {
        _clearUser();
        return;
      }
    } catch (_) {
      // 通信エラーなどは無視
    }
  }

  /// ユーザー情報取得
  Future<AuthUser> fetchUser() async {
    // 時間のかかるAPIは後から取得する
    try {
      final freshUser = await _authRepository.fetchUserFromApi();
      state = state.copyWith(freshUser);
      return freshUser;
    } on ApiException catch (e) {
      // 認証エラーならログアウト処理
      if (e.type == ApiErrorType.unauthorized) {
        _clearUser();
      }
      rethrow;
    } catch (_) {
      // 通信エラーなどは無視
      rethrow;
    }
  }

  /// ログアウト
  Future<void> logout() async {
    await _authRepository.logout();
    _clearUser();
  }

  /// 退会(アカウント削除)
  Future<void> withdrawal() async {
    // 退会APIの実行でクラウド側のデータは自動的に削除される
    await _authRepository.withdrawal();
    // ローカルのデータを全て非公開に戻してUserIdもnullに変更する
    _resetPublicPaymentSources();
    _clearUser();
  }

  /// 公開フラグをリセット
  void _resetPublicPaymentSources() {
    final allPaymentSources = _realmRepository.fetchAll<PaymentSource>();
    final targetSourceIds = allPaymentSources
        .where((source) => source.publicUserId != null)
        .map((source) => source.id)
        .toList();
    for (var id in targetSourceIds) {
      _realmRepository.updateById(id, (PaymentSource paymentSource) {
        paymentSource.publicUserId = null;
        paymentSource.isPublicName = false;
      });
    }
  }

  Future<void> _clearUser() async {
    // ローカルキャッシュユーザーを削除
    await _authRepository.clearCachedUser();
    // UIも更新
    state = state.copyWith(null);
  }

  /// プロフィール情報更新
  Future<void> updateProfile({
    required String name,
    required String region,
    required DateTime birthday,
    required String job,
    required String jobCategory,
  }) async {
    await _authRepository.updateProfile(
        name: name,
        region: region,
        birthday: birthday,
        job: job,
        jobCategory: jobCategory
    );
    final updateUser = state.user?.copyWith(
        name: name,
        region: region,
        birthday: birthday,
        job: job
    );
    state = state.copyWith(updateUser);
  }

  /// プロフィール情報更新
  Future<void> updatePolicyProfile() async {
    await _authRepository.updatePolicyProfile(
        publishPolicyVersion: PublicPolicyConfig.version,
    );
    // 同意日が更新されているので念のため再度取得する
    await fetchUser();
  }

}
