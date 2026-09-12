// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annual_target.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class AnnualTarget extends _AnnualTarget
    with RealmEntity, RealmObjectBase, RealmObject {
  AnnualTarget(int year, int targetAmount) {
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set(this, 'targetAmount', targetAmount);
  }

  AnnualTarget._();

  @override
  int get year => RealmObjectBase.get<int>(this, 'year') as int;
  @override
  set year(int value) => RealmObjectBase.set(this, 'year', value);

  @override
  int get targetAmount => RealmObjectBase.get<int>(this, 'targetAmount') as int;
  @override
  set targetAmount(int value) =>
      RealmObjectBase.set(this, 'targetAmount', value);

  @override
  Stream<RealmObjectChanges<AnnualTarget>> get changes =>
      RealmObjectBase.getChanges<AnnualTarget>(this);

  @override
  Stream<RealmObjectChanges<AnnualTarget>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<AnnualTarget>(this, keyPaths);

  @override
  AnnualTarget freeze() => RealmObjectBase.freezeObject<AnnualTarget>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'year': year.toEJson(),
      'targetAmount': targetAmount.toEJson(),
    };
  }

  static EJsonValue _toEJson(AnnualTarget value) => value.toEJson();
  static AnnualTarget _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'year': EJsonValue year, 'targetAmount': EJsonValue targetAmount} =>
        AnnualTarget(fromEJson(year), fromEJson(targetAmount)),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AnnualTarget._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      AnnualTarget,
      'AnnualTarget',
      [
        SchemaProperty('year', RealmPropertyType.int, primaryKey: true),
        SchemaProperty('targetAmount', RealmPropertyType.int),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
