import 'package:salary/core/providers/premium_function_state_notifier.dart';

/// CSVエクスポートを利用できるプレミアム状態を判定する。
class SalaryExportAccess {
  const SalaryExportAccess._();

  static bool isAllowed(PremiumFunctionState premiumState) {
    return premiumState.isPremiumFullUnlocked ||
        premiumState.isPremiumFeatureUnlocked;
  }
}
