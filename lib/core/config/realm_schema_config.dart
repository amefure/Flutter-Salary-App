
class RealmSchemaConfig {
  /// 1・・・初回
  /// 2・・・[_PaymentSource]に[memo]プロパティを追加
  /// 3・・・[_Salary]に[isBonus]プロパティを追加
  /// 4・・・[_PaymentSource]に[isMain]プロパティを追加
  static int schemaVersion = 4;
}