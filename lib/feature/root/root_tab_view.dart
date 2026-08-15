import 'package:flutter/cupertino.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RootTabView extends ConsumerStatefulWidget {
  const RootTabView({super.key});

  @override
  ConsumerState<RootTabView> createState() => _RootTabViewViewState();
}

class _RootTabViewViewState extends ConsumerState<RootTabView> {
  late CupertinoTabController _tabController;

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
    // 例として PublicHistory や特定タブに切り替わったときの処理
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
          // Enum を使って安全にタブを指定して移動
          _tabController.index = RootTabType.publicHistory.tabIndex;
        },
        onCloseButtonPressed: () {
          viewModel.markAsShownPremiumIntro();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rootTabProvider);
    listenDeepLinkDestination();

    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        height: 60,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'MyHistory',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'MyData',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_pie_fill),
            label: 'Analysis',
          ),
          state.shouldShowPremiumTabBadge == true
              ? _timeLineTabItemAddBadge()
              : _timeLineTabItem(),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_alt_fill),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return _getPage(RootTabType.fromIndex(index));
          },
        );
      },
    );
  }

  BottomNavigationBarItem _timeLineTabItem() {
    return const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.globe),
      label: 'PublicHistory',
    );
  }

  BottomNavigationBarItem _timeLineTabItemAddBadge() {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(CupertinoIcons.globe),
          Positioned(
            top: -5,
            right: -25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CustomColors.negative,
                borderRadius: BorderRadius.circular(20),
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
      label: 'PublicHistory',
    );
  }

  /// Enum を引数に受け取ることで、どの画面を返すかが一目でわかるようにする
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