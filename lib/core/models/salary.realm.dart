// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Salary extends _Salary with RealmEntity, RealmObjectBase, RealmObject {
  Salary(
    String id,
    int paymentAmount,
    int deductionAmount,
    int netSalary,
    DateTime createdAt,
    bool isBonus,
    String memo, {
    Iterable<AmountItem> paymentAmountItems = const [],
    Iterable<AmountItem> deductionAmountItems = const [],
    PaymentSource? source,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'paymentAmount', paymentAmount);
    RealmObjectBase.set(this, 'deductionAmount', deductionAmount);
    RealmObjectBase.set(this, 'netSalary', netSalary);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set<RealmList<AmountItem>>(
      this,
      'paymentAmountItems',
      RealmList<AmountItem>(paymentAmountItems),
    );
    RealmObjectBase.set<RealmList<AmountItem>>(
      this,
      'deductionAmountItems',
      RealmList<AmountItem>(deductionAmountItems),
    );
    RealmObjectBase.set(this, 'source', source);
    RealmObjectBase.set(this, 'isBonus', isBonus);
    RealmObjectBase.set(this, 'memo', memo);
  }

  Salary._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get paymentAmount =>
      RealmObjectBase.get<int>(this, 'paymentAmount') as int;
  @override
  set paymentAmount(int value) =>
      RealmObjectBase.set(this, 'paymentAmount', value);

  @override
  int get deductionAmount =>
      RealmObjectBase.get<int>(this, 'deductionAmount') as int;
  @override
  set deductionAmount(int value) =>
      RealmObjectBase.set(this, 'deductionAmount', value);

  @override
  int get netSalary => RealmObjectBase.get<int>(this, 'netSalary') as int;
  @override
  set netSalary(int value) => RealmObjectBase.set(this, 'netSalary', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  RealmList<AmountItem> get paymentAmountItems =>
      RealmObjectBase.get<AmountItem>(this, 'paymentAmountItems')
          as RealmList<AmountItem>;
  @override
  set paymentAmountItems(covariant RealmList<AmountItem> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<AmountItem> get deductionAmountItems =>
      RealmObjectBase.get<AmountItem>(this, 'deductionAmountItems')
          as RealmList<AmountItem>;
  @override
  set deductionAmountItems(covariant RealmList<AmountItem> value) =>
      throw RealmUnsupportedSetError();

  @override
  PaymentSource? get source =>
      RealmObjectBase.get<PaymentSource>(this, 'source') as PaymentSource?;
  @override
  set source(covariant PaymentSource? value) =>
      RealmObjectBase.set(this, 'source', value);

  @override
  bool get isBonus => RealmObjectBase.get<bool>(this, 'isBonus') as bool;
  @override
  set isBonus(bool value) => RealmObjectBase.set(this, 'isBonus', value);

  @override
  String get memo => RealmObjectBase.get<String>(this, 'memo') as String;
  @override
  set memo(String value) => RealmObjectBase.set(this, 'memo', value);

  @override
  Stream<RealmObjectChanges<Salary>> get changes =>
      RealmObjectBase.getChanges<Salary>(this);

  @override
  Stream<RealmObjectChanges<Salary>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Salary>(this, keyPaths);

  @override
  Salary freeze() => RealmObjectBase.freezeObject<Salary>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'paymentAmount': paymentAmount.toEJson(),
      'deductionAmount': deductionAmount.toEJson(),
      'netSalary': netSalary.toEJson(),
      'createdAt': createdAt.toEJson(),
      'paymentAmountItems': paymentAmountItems.toEJson(),
      'deductionAmountItems': deductionAmountItems.toEJson(),
      'source': source.toEJson(),
      'isBonus': isBonus.toEJson(),
      'memo': memo.toEJson(),
    };
  }

  static EJsonValue _toEJson(Salary value) => value.toEJson();
  static Salary _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'paymentAmount': EJsonValue paymentAmount,
        'deductionAmount': EJsonValue deductionAmount,
        'netSalary': EJsonValue netSalary,
        'createdAt': EJsonValue createdAt,
        'isBonus': EJsonValue isBonus,
        'memo': EJsonValue memo,
      } =>
        Salary(
          fromEJson(id),
          fromEJson(paymentAmount),
          fromEJson(deductionAmount),
          fromEJson(netSalary),
          fromEJson(createdAt),
          fromEJson(isBonus),
          fromEJson(memo),
          paymentAmountItems: fromEJson(ejson['paymentAmountItems']),
          deductionAmountItems: fromEJson(ejson['deductionAmountItems']),
          source: fromEJson(ejson['source']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Salary._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Salary, 'Salary', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('paymentAmount', RealmPropertyType.int),
      SchemaProperty('deductionAmount', RealmPropertyType.int),
      SchemaProperty('netSalary', RealmPropertyType.int),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty(
        'paymentAmountItems',
        RealmPropertyType.object,
        linkTarget: 'AmountItem',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty(
        'deductionAmountItems',
        RealmPropertyType.object,
        linkTarget: 'AmountItem',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty(
        'source',
        RealmPropertyType.object,
        optional: true,
        linkTarget: 'PaymentSource',
      ),
      SchemaProperty('isBonus', RealmPropertyType.bool),
      SchemaProperty('memo', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class AmountItem extends _AmountItem
    with RealmEntity, RealmObjectBase, RealmObject {
  AmountItem(String id, String key, int value) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'value', value);
  }

  AmountItem._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get key => RealmObjectBase.get<String>(this, 'key') as String;
  @override
  set key(String value) => RealmObjectBase.set(this, 'key', value);

  @override
  int get value => RealmObjectBase.get<int>(this, 'value') as int;
  @override
  set value(int value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<AmountItem>> get changes =>
      RealmObjectBase.getChanges<AmountItem>(this);

  @override
  Stream<RealmObjectChanges<AmountItem>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AmountItem>(this, keyPaths);

  @override
  AmountItem freeze() => RealmObjectBase.freezeObject<AmountItem>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'key': key.toEJson(),
      'value': value.toEJson(),
    };
  }

  static EJsonValue _toEJson(AmountItem value) => value.toEJson();
  static AmountItem _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id, 'key': EJsonValue key, 'value': EJsonValue value} =>
        AmountItem(fromEJson(id), fromEJson(key), fromEJson(value)),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AmountItem._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      AmountItem,
      'AmountItem',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('key', RealmPropertyType.string),
        SchemaProperty('value', RealmPropertyType.int),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PaymentSource extends _PaymentSource
    with RealmEntity, RealmObjectBase, RealmObject {
  PaymentSource(
    String id,
    String name,
    int themaColor,
    bool isMain, {
    String? memo,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'themaColor', themaColor);
    RealmObjectBase.set(this, 'memo', memo);
    RealmObjectBase.set(this, 'isMain', isMain);
  }

  PaymentSource._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get themaColor => RealmObjectBase.get<int>(this, 'themaColor') as int;
  @override
  set themaColor(int value) => RealmObjectBase.set(this, 'themaColor', value);

  @override
  String? get memo => RealmObjectBase.get<String>(this, 'memo') as String?;
  @override
  set memo(String? value) => RealmObjectBase.set(this, 'memo', value);

  @override
  bool get isMain => RealmObjectBase.get<bool>(this, 'isMain') as bool;
  @override
  set isMain(bool value) => RealmObjectBase.set(this, 'isMain', value);

  @override
  Stream<RealmObjectChanges<PaymentSource>> get changes =>
      RealmObjectBase.getChanges<PaymentSource>(this);

  @override
  Stream<RealmObjectChanges<PaymentSource>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PaymentSource>(this, keyPaths);

  @override
  PaymentSource freeze() => RealmObjectBase.freezeObject<PaymentSource>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'themaColor': themaColor.toEJson(),
      'memo': memo.toEJson(),
      'isMain': isMain.toEJson(),
    };
  }

  static EJsonValue _toEJson(PaymentSource value) => value.toEJson();
  static PaymentSource _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'themaColor': EJsonValue themaColor,
        'isMain': EJsonValue isMain,
      } =>
        PaymentSource(
          fromEJson(id),
          fromEJson(name),
          fromEJson(themaColor),
          fromEJson(isMain),
          memo: fromEJson(ejson['memo']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PaymentSource._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PaymentSource,
      'PaymentSource',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('themaColor', RealmPropertyType.int),
        SchemaProperty('memo', RealmPropertyType.string, optional: true),
        SchemaProperty('isMain', RealmPropertyType.bool),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
