import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';

/// Realm DB Repository クラス
/// シングルトン設計
/// ```
/// // 普通にインスタンス化するだけでシングルトンになる
/// final repository = RealmRepository();
/// ```
class RealmRepository {
  /// シングルトンインスタンスを保持
  static final RealmRepository _instance = RealmRepository._internal();
  /// factory constructor
  factory RealmRepository() => _instance;

  /// Private Named constructor
  RealmRepository._internal() {
    // 対象のモデルを設定
    final config = Configuration.local([
      Salary.schema,
      PaymentSource.schema,
      AmountItem.schema,
    ]);
    _realm = Realm(config);
  }

  /// Realm 本体
  late Realm _realm;

  /// ジェネリクスで指定した全データを取得
  List<T> fetchAll<T extends RealmObject>() {
    return _realm.all<T>().toList();
  }

  /// ジェネリクスで指定した新しいデータを追加
  void add<T extends RealmObject>(T item) {
    _realm.write(() {
      _realm.add(item);
    });
  }

  /// ジェネリクスで指定したデータを削除
  void delete<T extends RealmObject>(T item) {
    _realm.write(() {
      _realm.delete(item);
    });
  }
  /// Realmを終了
  void dispose() {
    _realm.close();
  }
}
