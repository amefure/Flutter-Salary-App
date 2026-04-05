import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/config/public_policy_config.dart';
import 'package:salary/core/models/exception/CommonException.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/feature/charts/chart_salary_view_model.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/feature/premium/data/public_salary_repository_impl.dart';
import 'package:salary/feature/premium/domain/model/public_salary.dart';
import 'package:salary/feature/premium/domain/public_salary_repository.dart';
import 'package:salary/feature/salary/data/salary_repository_impl.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_state.dart';
import 'package:salary/feature/salary/domain/salary_repository.dart';
import 'package:salary/feature/salary/list_salary/list_salary_view_model.dart';
import 'package:equatable/equatable.dart';

/// StateNotifierProviderの引数にしているためEquatableに準拠させておく
class DetailSalaryArgsData extends Equatable {
  final String id;
  /// 公開されたものかどうか(trueならクラウドからデータをフェッチする)
  final bool isPublic;

  const DetailSalaryArgsData({
    required this.id,
    required this.isPublic
  });

  @override
  List<Object?> get props => [id, isPublic];
}

final detailSalaryProvider =
StateNotifierProvider.autoDispose.family<DetailSalaryViewModel, DetailSalaryState, DetailSalaryArgsData>(
      (ref, args) {
    final repository = RealmDataSource();
    final salaryRepository = ref.read(salaryRepositoryProvider);
    final publicSalaryRepository = ref.read(publicSalaryRepositoryProvider);
    final vm = DetailSalaryViewModel(
        ref,
        repository,
        salaryRepository,
        publicSalaryRepository
    );
    if (args.isPublic) {
      /// build完了後に実行
      Future.microtask(() => vm.loadCloudSalary(args.id));
    } else {
      vm.loadLocalSalary(args.id);
    }
    return vm;
  },
);

class DetailSalaryViewModel extends StateNotifier<DetailSalaryState> {
  final Ref _ref;

  final RealmDataSource _localRepository;
  final SalaryRepository _salaryRepository;
  final PublicSalaryRepository _publicSalaryRepository;

  /// 初期インスタンス化
  DetailSalaryViewModel(
      this._ref,
      this._localRepository,
      this._salaryRepository,
      this._publicSalaryRepository
      ) : super(DetailSalaryState(salary: null));

  /// クラウド から Salary を取得（Single Source of Truth設計)
  void loadCloudSalary(String id) async {
    await _ref.runWithGlobalHandling(() async {
      final publicSalary = await _publicSalaryRepository.fetchById(id: id);
      state = state.copyWith(salary: publicSalary.toDomainLocal());
    });
  }

  /// Realm から Salary を取得（Single Source of Truth設計)
  void loadLocalSalary(String id) {
    final item = _localRepository.fetchById<Salary>(id);
    state = state.copyWith(salary: item?.freeze());
  }

  /// 詳細画面で表示対象のデータをリセット
  void _resetSalary() {
    state = state.copyWith(salary: null);
  }

  /// 削除
  Future<bool> delete(Salary salary) async {
    if (salary.source?.isPublic == true) {
      return await _ref.runWithGlobalHandling(() async {
        /// 公開済みのデータは削除前に条件件数を下回らないかチェックする
        final isOver = _checkIsOverSalariesCount(salary.source);
        if (!isOver) {
          /// 下回るならダイアログを出して終了
          throw const CommonException(message: '公開中の支払い元のためこれ以上削除できません。');
        }
        // クラウド登録
        await _salaryRepository.delete(salaries: [salary]);
        // 削除前にnullにして画面を更新
        _resetSalary();
        // 削除処理
        _localRepository.deleteById<Salary>(salary.id);
        // MyData画面のリフレッシュ
        _ref.read(chartSalaryProvider.notifier).refresh();
        // Homeリスト画面のリフレッシュ
        _ref.read(listSalaryProvider.notifier).refresh();
      });
    } else {
      // 削除前にnullにして画面を更新
      _resetSalary();
      // 削除処理
      _localRepository.deleteById<Salary>(salary.id);
      // MyData画面のリフレッシュ
      _ref.read(chartSalaryProvider.notifier).refresh();
      // Homeリスト画面のリフレッシュ
      _ref.read(listSalaryProvider.notifier).refresh();
    }
    return true;
  }

  /// 削除した際に公開条件件数を下回らないかをチェックする
  /// 上回っていればtrue
  bool _checkIsOverSalariesCount(PaymentSource? target) {
    final targetSalaries = _fetchAllLocalSalaries(target);
    final deletedCount = targetSalaries.length - 1;
    if (target?.isMain == true) {
      return deletedCount >= PublicPolicyConfig.mainMinSalaryCountForPublic;
    } else {
      return deletedCount >= PublicPolicyConfig.subMinSalaryCountForPublic;
    }
  }

  /// 全取得
  List<Salary> _fetchAllLocalSalaries(PaymentSource? target) {
    final allSalaries = _localRepository.fetchAll<Salary>();
    /// 対象PaymentSourceの給与のみ抽出
    final targetSalaries = allSalaries
        .where((salary) => salary.source?.id == target?.id)
        .toList();
    return targetSalaries;
  }
}
