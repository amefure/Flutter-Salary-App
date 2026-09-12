import 'package:flutter/cupertino.dart';

enum RootTabType {
  history(0, 'MyHistory', Icon(CupertinoIcons.list_bullet)),
  data(1, 'MyData', Icon(CupertinoIcons.chart_bar_alt_fill)),
  analysis(2, 'Analysis', Icon(CupertinoIcons.chart_pie_fill)),
  publicHistory(3, 'PublicHistory', Icon(CupertinoIcons.globe)),
  settings(4, 'Settings', Icon(CupertinoIcons.gear_alt_fill));

  final int tabIndex;
  final String label;
  final Widget icon;

  const RootTabType(this.tabIndex, this.label, this.icon);

  static RootTabType fromIndex(int tabIndex) {
    return RootTabType.values.firstWhere(
          (tab) => tab.tabIndex == tabIndex,
      orElse: () => RootTabType.history,
    );
  }
}

class RootTabState {

  /// プレミアムタブにバッジを表示すべきかどうか
  final bool? shouldShowPremiumTabBadge;

  const RootTabState({
    this.shouldShowPremiumTabBadge,
  });

  RootTabState copyWith({
    bool? shouldShowPremiumTabBadge,
  }) {
    return RootTabState(
      shouldShowPremiumTabBadge: shouldShowPremiumTabBadge ?? this.shouldShowPremiumTabBadge,
    );
  }
}