import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import 'package:salary/views/input_salary_view.dart';
import '../repository/realm_repository.dart';
import '../models/salary.dart';

class SalaryListView extends StatefulWidget {
  const SalaryListView({super.key});

  @override
  _SalaryListViewState createState() => _SalaryListViewState();
}

class _SalaryListViewState extends State<SalaryListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop List')),
      body: Consumer<SalaryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.salaries.isEmpty) {
            return Center(child: Text('データがありません'));
          }
          return ListView.builder(
            itemCount: viewModel.salaries.length,
            itemBuilder: (context, index) {
              final salary = viewModel.salaries[index];
              return ListTile(
                title: Text('手取り: ${salary.netSalary}円'),
                subtitle: Text('登録日: ${salary.createdAt}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.delete(salary);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalView(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// モーダル画面を表示
  void showModalView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return InputSalaryView();
      },
    );
  }

}
