import 'package:realm/realm.dart';
import 'package:salary/models/config/realm_schema_config.dart';
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
    final config = Configuration.local(
      [
        Salary.schema,
        PaymentSource.schema,
        AmountItem.schema,
      ],
      schemaVersion: RealmSchemaConfig.schemaVersion,
    );
    _realm = Realm(config);
  }

  /// Realm 本体
  late Realm _realm;

  /// ジェネリクスで指定した全データを取得
  List<T> fetchAll<T extends RealmObject>() {
    return _realm.all<T>().freeze().toList();
  }

  /// ジェネリクスで指定した対象IDのデータデータを取得
  T? fetchById<T extends RealmObject>(
      String id
      ) {
    // ID で検索
    final item = _realm.find<T>(id);
    return item?.freeze() as T;
  }

  /// ジェネリクスで指定した新しいデータを追加
  void add<T extends RealmObject>(T item) {
    _realm.write(() {
      _realm.add(item);
    });
  }

  /// ID を指定してデータを更新
  void updateById<T extends RealmObject>(
    String id,
    void Function(T) updateCallback,
  ) {
    final item = _realm.find<T>(id); // ID で検索
    if (item != null) {
      _realm.write(() {
        updateCallback(item);
        _realm.add(item, update: true); // 既存データを更新
      });
    }
  }

  /// ジェネリクスで指定したデータを削除
  void deleteById<T extends RealmObject>(String id) {
    _realm.write(() {
      final target = _realm.find<T>(id); // ID で検索
      if (target != null) {
        _realm.delete(target);
      }
    });
  }

  /// Realmを終了
  void dispose() {
    _realm.close();
  }
}
