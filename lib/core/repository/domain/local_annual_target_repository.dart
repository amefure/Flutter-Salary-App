import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/data_source/realm_data_source.dart';
import 'package:salary/core/models/annual_target.dart';

final localAnnualTargetRepositoryProvider =
Provider<LocalAnnualTargetRepository>((ref) {
  return LocalAnnualTargetRepository(RealmDataSource());
});

/// 年間目標のローカル永続化を担当するRepository。
class LocalAnnualTargetRepository {
  final IRealmDataSource _dataSource;

  LocalAnnualTargetRepository(this._dataSource);

  List<AnnualTarget> fetchAll() {
    final targets = _dataSource.fetchAll<AnnualTarget>();
    targets.sort((a, b) => b.year.compareTo(a.year));
    return targets;
  }

  AnnualTarget? findByYear(int year) {
    return _dataSource.findFirst<AnnualTarget>('year == \$0', [year]);
  }

  /// 年をキーにUPSERTする。同じ年を保存しても履歴が重複しない。
  void save({required int year, required int targetAmount}) {
    _dataSource.addAll([AnnualTarget(year, targetAmount)]);
  }

  /// 【追加】指定した年の目標を削除する
  /// 指定した年の目標を削除する
  void delete(int year) {
    _dataSource.deleteAnnualTargetByYear(year);
  }
}