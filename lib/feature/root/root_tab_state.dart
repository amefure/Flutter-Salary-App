class RootTabState {
  /// 画面にポップアップを表示すべきかどうか
  final bool? shouldShowPremiumIntro;

  /// プレミアムタブにバッジを表示すべきかどうか
  final bool? shouldShowPremiumTabBadge;

  const RootTabState({
    this.shouldShowPremiumIntro,
    this.shouldShowPremiumTabBadge,
  });

  RootTabState copyWith({
    bool? shouldShowPremiumIntro,
    bool? shouldShowPremiumTabBadge,
  }) {
    return RootTabState(
      shouldShowPremiumIntro: shouldShowPremiumIntro ?? this.shouldShowPremiumIntro,
      shouldShowPremiumTabBadge: shouldShowPremiumTabBadge ?? this.shouldShowPremiumTabBadge,
    );
  }
}