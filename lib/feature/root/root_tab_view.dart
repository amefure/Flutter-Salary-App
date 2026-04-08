import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/overlay/new_premium_feature_dialog.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/charts/presentation/chart_salary_screen.dart';
import 'package:salary/feature/premium/premium_root/premium_root_screen.dart';
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
    final currentIndex = _tabController.index;
    if (currentIndex == 2) {
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
            _tabController.index = 2;
          },
          onCloseButtonPressed: () {
            viewModel.markAsShownPremiumIntro();
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rootTabProvider);
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        height: 60,
        items: [
          /// 0
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'MyHistory',
          ),
          /// 1
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'MyData',
          ),
          /// 2
          state.shouldShowPremiumTabBadge == true ? _timeLineTabItemAddBadge() : _timeLineTabItem(),
          /// 3
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_alt_fill),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return _getPage(index);
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

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const SalaryListScreen();
      case 1:
        return const ChartSalaryScreen();
      case 2:
        return const PremiumRootScreen();
      case 3:
        return const SettingScreen();
      default:
        return const SalaryListScreen();
    }
  }
}