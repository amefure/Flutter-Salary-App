import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/repository/realm_repository.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/salary_list_view.dart';

/// アプリのルート
void main() {
  final _repository = RealmRepository();
  // SalaryViewModelをProviderとしてセットする
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalaryViewModel(_repository)),
      ],
      child: MyApp(),
    ),
  );
}

/// アプリのルートWidget
/// テーマ用
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SalaryListView(),
    );
  }
}
