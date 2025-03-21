import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/repository/realm_repository.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/salary_list_view.dart';

void main() {
  runApp(MyApp());
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(
  //         create: (_) => SalaryViewModel(repository),
  //       ),
  //     ],
  //     child: MyApp(),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SalaryListView()
    );
  }
}
