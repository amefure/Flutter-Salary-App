import 'package:realm/realm.dart';

// 自動生成コード
part 'salary.realm.dart';

// RealmModelクラスは_(プライベート)なので同一ファイルに定義する

// 給料
@RealmModel()
class _Salary {
  @PrimaryKey()
  late String id;
  // 総支給
  late int paymentAmount;
  // 控除額
  late int deductionAmount;
  // 手取り額
  late int netSalary;
  // 登録日
  late DateTime createdAt;
  // 総支給構成要素
  late List<_AmountItem> paymentAmountItems;
   // 控除額構成要素
  late List<_AmountItem> deductionAmountItems;
  // 支払い元
  late _PaymentSource? source;
}

// 金額項目
@RealmModel()
class _AmountItem {
  late String key;
  late int value;
}

// 支払い元
// 会社や副業
@RealmModel()
class _PaymentSource {
  @PrimaryKey()
  late String id;

  late String name;
}
