import 'package:realm/realm.dart';

part 'annual_target.realm.dart';

/// 暦年ごとの年間目標を保存するRealmモデル。
///
/// [year]をプライマリキーにすることで、同じ年の目標を常に1件に
/// 保ち、保存時のUPSERTにも利用できる。
@RealmModel()
class _AnnualTarget {
  @PrimaryKey()
  late int year;

  /// 目標金額（円）
  late int targetAmount;
}
