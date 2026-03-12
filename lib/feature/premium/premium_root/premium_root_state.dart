enum PremiumTab {
  timeline(
    title: 'タイムライン',
    description: '''みんなの月単位での給料情報投稿を
時系列で確認できます。
    
▼ 確認できる項目
・総支給額
・手取り額
・支給月
・職種
・ボーナス
・職種
・地域
・年代
''',
  ),
  summary(
    title: 'サマリー',
    description: '''年別のデータをグラフで確認できます。
グラフは以下の項目でフィルタリングをかけることができます。

・対象年
・職種
・地域
・年代
''',
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