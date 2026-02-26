enum PremiumTab {
  timeline(
    title: 'タイムライン',
    description: 'みんなの月単位での給料情報投稿を時系列で確認できます。\n最新の情報をすぐチェックできます。',
  ),
  summary(
    title: 'サマリー',
    description: '月別・年別のデータを\nグラフで確認できます。',
  );

  final String title;
  final String description;

  const PremiumTab({
    required this.title,
    required this.description,
  });
}

class PremiumRootState {
  final PremiumTab currentTab;
  final bool isRefresh;

  PremiumRootState({
    required this.currentTab,
    required this.isRefresh
  });

  static PremiumRootState initial() {
    return PremiumRootState(
      currentTab: PremiumTab.timeline,
      isRefresh: false,
    );
  }

  PremiumRootState copyWith({
    PremiumTab? currentTab,
    bool? isRefresh,
  }) {
    return PremiumRootState(
        currentTab: currentTab ?? this.currentTab,
        isRefresh : isRefresh ?? this.isRefresh
    );
  }
}