import 'package:realm/realm.dart';
import 'package:salary/Models/salary.dart';

class RealmRepository {
  static final RealmRepository _instance = RealmRepository._internal();
  late Realm _realm;

  factory RealmRepository() => _instance;

  RealmRepository._internal() {
    List<SchemaObject> models = [
      Salary.schema,
      AmountItem.schema,
      PaymentSource.schema
    ];
    final config = Configuration.local(models);
    _realm = Realm(config);
  }

  /// **すべてのデータを取得**
  List<T> fetchAll<T extends RealmObject>() {
    return _realm.all<T>().toList();
  }

  /// **新しいデータを追加**
  void add<T extends RealmObject>(T item) {
    _realm.write(() {
      _realm.add(item);
    });
  }

  /// **データを削除**
  void delete<T extends RealmObject>(T item) {
    _realm.write(() {
      _realm.delete(item);
    });
  }

  void dispose() {
    _realm.close();
  }
}
