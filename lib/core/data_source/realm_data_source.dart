import 'package:realm/realm.dart';
import 'package:salary/core/config/realm_schema_config.dart';
import 'package:salary/core/models/salary.dart';

abstract class IRealmDataSource {
  /// 全データを取得
  List<T> fetchAll<T extends RealmObject>();

  /// 指定したIDのデータを取得
  T? fetchById<T extends RealmObject>(String id);

  /// クエリ条件にマッチする最初の1件を取得
  T? findFirst<T extends RealmObject>(String query, [List<Object?> args]);

  /// クエリ条件にマッチする全件を取得
  List<T> findByQuery<T extends RealmObject>(String query, [List<Object?> args]);

  /// 新しいデータを追加
  void add<T extends RealmObject>(T item);

  /// 一括で追加または更新（UPSERT）
  void addAll<T extends RealmObject>(Iterable<T> items);

  /// IDを指定してデータを更新
  void updateById<T extends RealmObject>(
      String id,
      void Function(T) updateCallback,
      );

  /// IDを指定してデータを削除
  void deleteById<T extends RealmObject>(String id);

  /// IDリストに基づいて一括削除
  void deleteByIds<T extends RealmObject>(Iterable<String> ids);

  /// リソースの解放
  void dispose();
}

/// Realm DB Repository クラス
/// シングルトン設計
/// ```
/// // 普通にインスタンス化するだけでシングルトンになる
/// final repository = RealmDataSource();
/// ```
class RealmDataSource implements IRealmDataSource{
  /// シングルトンインスタンスを保持
  static final RealmDataSource _instance = RealmDataSource._internal();

  /// factory constructor
  factory RealmDataSource() => _instance;

  /// Private Named constructor
  RealmDataSource._internal() {
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
  @override
  List<T> fetchAll<T extends RealmObject>() {
    return _realm.all<T>().freeze().toList();
  }

  /// ジェネリクスで指定した対象IDのデータデータを取得
  @override
  T? fetchById<T extends RealmObject>(
      String id
      ) {
    // ID で検索
    final item = _realm.find<T>(id);
    return item?.freeze() as T;
  }

  /// クエリ条件にマッチする最初の1件を取得
  /// query例: "name == $0", args例: ["支払元A"]
  @override
  T? findFirst<T extends RealmObject>(String query, [List<Object?> args = const []]) {
    final results = _realm.query<T>(query, args);
    return results.isEmpty ? null : results.first.freeze() as T;
  }

  /// クエリ条件にマッチする全件を取得
  @override
  List<T> findByQuery<T extends RealmObject>(String query, [List<Object?> args = const []]) {
    return _realm.query<T>(query, args).freeze().toList();
  }

  /// ジェネリクスで指定した新しいデータを追加
  @override
  void add<T extends RealmObject>(T item) {
    _realm.write(() {
      _realm.add(item);
    });
  }

  /// リストを受け取り、一括で追加または更新（UPSERT）を行う
  @override
  void addAll<T extends RealmObject>(Iterable<T> items) {
    _realm.write(() {
      // update: true：プライマリキーが一致するものは更新
      _realm.addAll(items, update: true);
    });
  }

  /// ID を指定してデータを更新
  @override
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
  @override
  void deleteById<T extends RealmObject>(String id) {
    _realm.write(() {
      final target = _realm.find<T>(id); // ID で検索
      if (target != null) {
        _realm.delete(target);
      }
    });
  }

  /// ジェネリクスで指定したデータをIDリストに基づいて一括削除
  @override
  void deleteByIds<T extends RealmObject>(Iterable<String> ids) {
    _realm.write(() {
      for (final id in ids) {
        final target = _realm.find<T>(id);
        if (target != null) {
          _realm.delete(target);
        }
      }
    });
  }

  /// Realmを終了
  @override
  void dispose() {
    _realm.close();
  }
}
