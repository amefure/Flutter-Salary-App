import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/common/overlay/new_premium_feature_dialog.dart';
import 'package:salary/core/deeplink/deep_link_destination.dart';
import 'package:salary/core/deeplink/deep_link_notifier.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/analysis/salary_analysis_screen.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';
import 'package:salary/feature/charts/presentation/chart_salary_screen.dart';
import 'package:salary/feature/premium/premium_root/premium_root_screen.dart';
import 'package:salary/feature/root/root_tab_state.dart';
import 'package:salary/feature/root/root_tab_view_model.dart';
import 'package:salary/feature/salary/list_salary/list_salary_screen.dart';
import 'package:salary/feature/settings/setting_screen.dart';

class RootTabView extends ConsumerStatefulWidget {
  const RootTabView({super.key});

  @override
  ConsumerState<RootTabView> createState() => _RootTabViewViewState();
}

class _RootTabViewViewState extends ConsumerState<RootTabView> {
  late CupertinoTabController _tabController;

  // 各タブのNavigatorを制御するためのキー（5タブ分）
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController();
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpdateInfoIfNeeded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final currentTab = RootTabType.fromIndex(_tabController.index);
    if (currentTab == RootTabType.publicHistory) {
      ref.read(rootTabProvider.notifier).markAsShownPremiumTab();
    }
  }

  void _showUpdateInfoIfNeeded() {
    final viewModel = ref.read(rootTabProvider.notifier);
    final state = ref.read(rootTabProvider);
    if (state.shouldShowPremiumIntro == true) {
      NewPremiumFeatureDialog.show(
        context,
        onDetailButtonPressed: () {
          viewModel.markAsShownPremiumIntro();
          _tabController.index = RootTabType.publicHistory.tabIndex;
        },
        onCloseButtonPressed: () {
          viewModel.markAsShownPremiumIntro();
        },
      );
    }
  }

  /// タブがタップされたときの処理（同じタブならスタックを先頭まで戻し、違うタブなら切り替える）
  void _handleTabPressed(int index) {
    if (_tabController.index == index) {
      navigatorKeys[index]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _tabController.index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rootTabProvider);
    listenDeepLinkDestination();

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      // キーボードでせり上がらないようにする
      resizeToAvoidBottomInset: false,
      child: Stack(
        children: [
          // 各タブの画面コンテンツ
          CupertinoTabScaffold(
            controller: _tabController,
            tabBar: CupertinoTabBar(
              backgroundColor: CupertinoColors.transparent,
              border: null,
              items: const [
                BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
                BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
                BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
                BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
                BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
              ],
            ),
            tabBuilder: (context, index) {
              return CupertinoTabView(
                navigatorKey: navigatorKeys[index],
                builder: (context) {
                  return _getPage(RootTabType.fromIndex(index));
                },
              );
            },
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context).withAlpha(220),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: CupertinoColors.separator.resolveFrom(context).withAlpha(50),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withAlpha(25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, CupertinoIcons.list_bullet, 'History'),
                    _buildNavItem(1, CupertinoIcons.chart_bar_alt_fill, 'Data'),
                    _buildNavItem(2, CupertinoIcons.chart_pie_fill, 'Analysis'),
                    _buildBadgeNavItem(3, CupertinoIcons.globe, 'Public', state.shouldShowPremiumTabBadge == true),
                    _buildNavItem(4, CupertinoIcons.gear_alt_fill, 'Settings'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconData, String label) {
    final isSelected = _tabController.index == index;
    final color = isSelected ? CustomColors.thema : CupertinoColors.systemGrey;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _handleTabPressed(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeNavItem(int index, IconData iconData, String label, bool hasBadge) {
    final isSelected = _tabController.index == index;
    final color = isSelected ? CustomColors.thema : CupertinoColors.systemGrey;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _handleTabPressed(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(iconData, color: color, size: 22),
              if (hasBadge)
                Positioned(
                  top: -6,
                  right: -20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: CustomColors.negative,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: CustomColors.negative.withAlpha(100),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CustomText(
                      text: 'NEW!',
                      color: CupertinoColors.white,
                      textSize: TextSize.SSS,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPage(RootTabType tabType) {
    switch (tabType) {
      case RootTabType.history:
        return const SalaryListScreen();
      case RootTabType.data:
        return const ChartSalaryScreen();
      case RootTabType.analysis:
        return const SalaryAnalysisScreen();
      case RootTabType.publicHistory:
        return const PremiumRootScreen();
      case RootTabType.settings:
        return const SettingScreen();
    }
  }

  /// ディープリンク遷移ハンドリング観測
  void listenDeepLinkDestination() {
    ref.listen<DeepLinkDestination>(deepLinkProvider, (previous, next) {
      /// 【MUST】バックグラウンドから起動する場合に備えてフレーム描画が終わった直後に実行するようにする
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        switch (next) {
          case DeepLinkNone():
            break;
          case DeepLinkRegisterAccount():
            final state = ref.watch(authStateProvider);
            if (state.isLogin) {
              await AppDialog.show(
                context: context,
                message: 'すでにログイン済みです。',
                type: DialogType.error,
              );
            } else {
              final navigator = Navigator.of(context, rootNavigator: true);
              navigator.push<void>(
                CupertinoPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (modalContext) => RegisterAccountScreen(
                    deepLinkRegisterAccount: next,
                    onClose: () => navigator.pop(),
                  ),
                ),
              ).then((_) => ref.read(deepLinkProvider.notifier).clear());
            }
            break;
        }
      });
    });
  }
}