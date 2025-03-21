import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';

class RealmRepository {
  static final RealmRepository _instance = RealmRepository._internal();
  late Realm _realm;

  factory RealmRepository() => _instance;

  RealmRepository._internal() {
    final config = Configuration.local([
      Salary.schema,
      PaymentSource.schema,
      AmountItem.schema,
    ]);
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
