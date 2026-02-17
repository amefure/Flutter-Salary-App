import 'package:flutter/cupertino.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/charts/view/chart_salary_screen.dart';
import 'package:salary/feature/domain/list_salary/list_salary_view.dart';
import 'package:salary/feature/setting/home/setting_view.dart';
import 'package:salary/feature/timeline/time_line_root_screen.dart';

class RootTabViewView extends StatefulWidget {
  const RootTabViewView({super.key});

  @override
  State<RootTabViewView> createState() => _RootTabViewViewState();
}

class _RootTabViewViewState extends State<RootTabViewView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: 60,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'MyData',
          ),
          _timeLineTabItem(),
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
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [

          const Icon(CupertinoIcons.globe),

          /// バッジ
          Positioned(
            right: -18,
            top: -3,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: CustomColors.negative,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: const Center(
                child: CustomText(
                  text: 'NEW',
                  textSize: TextSize.SSS,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      label: 'Timeline',
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const SalaryListScreen();
      case 1:
        return const ChartSalaryScreen();
      case 2:
        return const TimeLineRootScreen();
      case 3:
        return const SettingView();
      default:
        return const SalaryListView();
    }
  }
}
