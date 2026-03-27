import 'package:realm/realm.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/config/json_keys.dart';

// 自動生成コード
part 'salary.realm.dart';

/// RealmModelクラスは_(プライベート)なので同一ファイルに定義する
/// テーブル情報を変更したら $ dart run realm generate を実行

/// 給料
@RealmModel()
class _Salary {
  @PrimaryKey()
  late String id;
  /// 総支給
  late int paymentAmount;
  /// 控除額
  late int deductionAmount;
  /// 手取り額
  late int netSalary;
  /// 登録(支払い)日
  late DateTime createdAt;
  /// 総支給構成要素
  late List<_AmountItem> paymentAmountItems;
  /// 控除額構成要素
  late List<_AmountItem> deductionAmountItems;
  /// 支払い元
  late _PaymentSource? source;
  /// ボーナスかどうか
  late bool isBonus;
  /// メモ
  late String memo;

  Map<String, dynamic> toJson() {
    return {
      SalaryJsonKeys.id: id,
      SalaryJsonKeys.paymentAmount: paymentAmount,
      SalaryJsonKeys.deductionAmount: deductionAmount,
      SalaryJsonKeys.netSalary: netSalary,
      SalaryJsonKeys.paidAt: createdAt.toIso8601String(),
      SalaryJsonKeys.paymentSourceId: source?.id,
      SalaryJsonKeys.isBonus: isBonus,
      SalaryJsonKeys.memo: memo,
      SalaryJsonKeys.paymentItems: paymentAmountItems.map((e) => e.toJson()).toList(),
      SalaryJsonKeys.deductionItems: deductionAmountItems.map((e) => e.toJson()).toList(),
    };
  }

}

/// 金額項目
@RealmModel()
class _AmountItem {
  @PrimaryKey()
  late String id;
  late String key;
  late int value;

  Map<String, dynamic> toJson() {
    return {
      AmountItemJsonKeys.id: id,
      AmountItemJsonKeys.key: key,
      AmountItemJsonKeys.value: value,
    };
  }
}

/// 支払い元
/// 会社や副業
@RealmModel()
class _PaymentSource {
  @PrimaryKey()
  late String id;
  /// 名称
  late String name;
  /// カラー them"e"Colorのスペルミス
  late int themaColor;
  /// MEMO
  late String? memo;
  /// 本業フラグ
  late bool isMain;
  /// 対象ユーザーID(公開)
  late int? publicUserId;
  /// 支払い元名の公開許容フラグ
  late bool isPublicName;

  /// ThemaColor に変換
  ThemaColor get themaColorEnum => ThemaColor.fromValue(themaColor);

  /// 公開済みかどうか
  bool get isPublic => publicUserId != null;

  /// ThemaColor を設定
  set themaColorEnum(ThemaColor color) => themaColor = color.value;
}
