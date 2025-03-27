import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/views/salary/list_salary_view.dart';
import 'package:salary/views/setting/setting_view.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_fill),
            label: "STATS",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_alt_fill),
            label: "SETTINGS",
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

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const SalaryListView();
      case 1:
        return const SalaryListView();
      case 2:
        return const SettingView();
      default:
        return const SalaryListView();
    }
  }
}
