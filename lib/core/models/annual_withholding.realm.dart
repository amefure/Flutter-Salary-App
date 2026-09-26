// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annual_withholding.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class AnnualWithholding extends _AnnualWithholding
    with RealmEntity, RealmObjectBase, RealmObject {
  AnnualWithholding(
    String id,
    int year,
    String paymentSourceId,
    int paymentAmount,
    int deductionAmount,
    int totalExemptionAmount,
    int incomeTaxAmount,
    int socialInsuranceAmount,
    int lifeInsuranceDeduction,
    int earthquakeInsuranceDeduction,
    int spouseDeductionAmount,
    int housingLoanDeduction,
    String memo,
    DateTime createdAt,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set(this, 'paymentSourceId', paymentSourceId);
    RealmObjectBase.set(this, 'paymentAmount', paymentAmount);
    RealmObjectBase.set(this, 'deductionAmount', deductionAmount);
    RealmObjectBase.set(this, 'totalExemptionAmount', totalExemptionAmount);
    RealmObjectBase.set(this, 'incomeTaxAmount', incomeTaxAmount);
    RealmObjectBase.set(this, 'socialInsuranceAmount', socialInsuranceAmount);
    RealmObjectBase.set(this, 'lifeInsuranceDeduction', lifeInsuranceDeduction);
    RealmObjectBase.set(
      this,
      'earthquakeInsuranceDeduction',
      earthquakeInsuranceDeduction,
    );
    RealmObjectBase.set(this, 'spouseDeductionAmount', spouseDeductionAmount);
    RealmObjectBase.set(this, 'housingLoanDeduction', housingLoanDeduction);
    RealmObjectBase.set(this, 'memo', memo);
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  AnnualWithholding._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get year => RealmObjectBase.get<int>(this, 'year') as int;
  @override
  set year(int value) => RealmObjectBase.set(this, 'year', value);

  @override
  String get paymentSourceId =>
      RealmObjectBase.get<String>(this, 'paymentSourceId') as String;
  @override
  set paymentSourceId(String value) =>
      RealmObjectBase.set(this, 'paymentSourceId', value);

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
  int get totalExemptionAmount =>
      RealmObjectBase.get<int>(this, 'totalExemptionAmount') as int;
  @override
  set totalExemptionAmount(int value) =>
      RealmObjectBase.set(this, 'totalExemptionAmount', value);

  @override
  int get incomeTaxAmount =>
      RealmObjectBase.get<int>(this, 'incomeTaxAmount') as int;
  @override
  set incomeTaxAmount(int value) =>
      RealmObjectBase.set(this, 'incomeTaxAmount', value);

  @override
  int get socialInsuranceAmount =>
      RealmObjectBase.get<int>(this, 'socialInsuranceAmount') as int;
  @override
  set socialInsuranceAmount(int value) =>
      RealmObjectBase.set(this, 'socialInsuranceAmount', value);

  @override
  int get lifeInsuranceDeduction =>
      RealmObjectBase.get<int>(this, 'lifeInsuranceDeduction') as int;
  @override
  set lifeInsuranceDeduction(int value) =>
      RealmObjectBase.set(this, 'lifeInsuranceDeduction', value);

  @override
  int get earthquakeInsuranceDeduction =>
      RealmObjectBase.get<int>(this, 'earthquakeInsuranceDeduction') as int;
  @override
  set earthquakeInsuranceDeduction(int value) =>
      RealmObjectBase.set(this, 'earthquakeInsuranceDeduction', value);

  @override
  int get spouseDeductionAmount =>
      RealmObjectBase.get<int>(this, 'spouseDeductionAmount') as int;
  @override
  set spouseDeductionAmount(int value) =>
      RealmObjectBase.set(this, 'spouseDeductionAmount', value);

  @override
  int get housingLoanDeduction =>
      RealmObjectBase.get<int>(this, 'housingLoanDeduction') as int;
  @override
  set housingLoanDeduction(int value) =>
      RealmObjectBase.set(this, 'housingLoanDeduction', value);

  @override
  String get memo => RealmObjectBase.get<String>(this, 'memo') as String;
  @override
  set memo(String value) => RealmObjectBase.set(this, 'memo', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  Stream<RealmObjectChanges<AnnualWithholding>> get changes =>
      RealmObjectBase.getChanges<AnnualWithholding>(this);

  @override
  Stream<RealmObjectChanges<AnnualWithholding>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<AnnualWithholding>(this, keyPaths);

  @override
  AnnualWithholding freeze() =>
      RealmObjectBase.freezeObject<AnnualWithholding>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'year': year.toEJson(),
      'paymentSourceId': paymentSourceId.toEJson(),
      'paymentAmount': paymentAmount.toEJson(),
      'deductionAmount': deductionAmount.toEJson(),
      'totalExemptionAmount': totalExemptionAmount.toEJson(),
      'incomeTaxAmount': incomeTaxAmount.toEJson(),
      'socialInsuranceAmount': socialInsuranceAmount.toEJson(),
      'lifeInsuranceDeduction': lifeInsuranceDeduction.toEJson(),
      'earthquakeInsuranceDeduction': earthquakeInsuranceDeduction.toEJson(),
      'spouseDeductionAmount': spouseDeductionAmount.toEJson(),
      'housingLoanDeduction': housingLoanDeduction.toEJson(),
      'memo': memo.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(AnnualWithholding value) => value.toEJson();
  static AnnualWithholding _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'year': EJsonValue year,
        'paymentSourceId': EJsonValue paymentSourceId,
        'paymentAmount': EJsonValue paymentAmount,
        'deductionAmount': EJsonValue deductionAmount,
        'totalExemptionAmount': EJsonValue totalExemptionAmount,
        'incomeTaxAmount': EJsonValue incomeTaxAmount,
        'socialInsuranceAmount': EJsonValue socialInsuranceAmount,
        'lifeInsuranceDeduction': EJsonValue lifeInsuranceDeduction,
        'earthquakeInsuranceDeduction': EJsonValue earthquakeInsuranceDeduction,
        'spouseDeductionAmount': EJsonValue spouseDeductionAmount,
        'housingLoanDeduction': EJsonValue housingLoanDeduction,
        'memo': EJsonValue memo,
        'createdAt': EJsonValue createdAt,
      } =>
        AnnualWithholding(
          fromEJson(id),
          fromEJson(year),
          fromEJson(paymentSourceId),
          fromEJson(paymentAmount),
          fromEJson(deductionAmount),
          fromEJson(totalExemptionAmount),
          fromEJson(incomeTaxAmount),
          fromEJson(socialInsuranceAmount),
          fromEJson(lifeInsuranceDeduction),
          fromEJson(earthquakeInsuranceDeduction),
          fromEJson(spouseDeductionAmount),
          fromEJson(housingLoanDeduction),
          fromEJson(memo),
          fromEJson(createdAt),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AnnualWithholding._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      AnnualWithholding,
      'AnnualWithholding',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('year', RealmPropertyType.int),
        SchemaProperty('paymentSourceId', RealmPropertyType.string),
        SchemaProperty('paymentAmount', RealmPropertyType.int),
        SchemaProperty('deductionAmount', RealmPropertyType.int),
        SchemaProperty('totalExemptionAmount', RealmPropertyType.int),
        SchemaProperty('incomeTaxAmount', RealmPropertyType.int),
        SchemaProperty('socialInsuranceAmount', RealmPropertyType.int),
        SchemaProperty('lifeInsuranceDeduction', RealmPropertyType.int),
        SchemaProperty('earthquakeInsuranceDeduction', RealmPropertyType.int),
        SchemaProperty('spouseDeductionAmount', RealmPropertyType.int),
        SchemaProperty('housingLoanDeduction', RealmPropertyType.int),
        SchemaProperty('memo', RealmPropertyType.string),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
