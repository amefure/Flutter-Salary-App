import 'package:realm/realm.dart';

part 'annual_withholding.realm.dart';

@RealmModel()
class _AnnualWithholding {
  @PrimaryKey()
  late String id;

  late int year;

  late String paymentSourceId;

  late int paymentAmount;

  late int deductionAmount;

  late int totalExemptionAmount;

  late int incomeTaxAmount;

  late int socialInsuranceAmount;
  late int lifeInsuranceDeduction;
  late int earthquakeInsuranceDeduction;
  late int spouseDeductionAmount;
  late int housingLoanDeduction;

  late String memo;

  late DateTime createdAt;
}