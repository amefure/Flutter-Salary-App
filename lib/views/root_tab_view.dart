import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/views/salary_list_view.dart';

class RootTabViewView extends StatefulWidget {
  const RootTabViewView({super.key});

  @override
  State<RootTabViewView> createState() => _RootTabViewViewState();
}

class _RootTabViewViewState extends State<RootTabViewView> {
  int _currentIndex = 0;

  final _pages = [
    const SalaryListView(),
    const SalaryListView(),
    const SalaryListView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "HOME"),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages.elementAt(_currentIndex),
    );
  }
}
