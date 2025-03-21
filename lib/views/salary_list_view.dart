import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/viewmodels/salary_viewmodel.dart';
import '../repository/realm_repository.dart';
import '../models/salary.dart';

class SalaryListView extends StatefulWidget {
  const SalaryListView({super.key});

  @override
  _SalaryListViewState createState() => _SalaryListViewState();
}

class _SalaryListViewState extends State<SalaryListView> {
  final RealmRepository _realmService = RealmRepository();

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
                    _realmService.delete(salary);
                    setState(() {}); // UIを更新
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddShopDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddShopDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Shop"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter shop name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newSalary = Salary(
                  Uuid.v4().toString(),
                  500000,
                  100000,
                  400000,
                  DateTime.now(),
                  // paymentAmountItems: [
                  //   AmountItem('基本給', 400000),
                  //   AmountItem('手当', 100000),
                  // ],
                  // deductionAmountItems: [
                  //   AmountItem('税金', 50000),
                  //   AmountItem('保険', 50000),
                  // ],
                  // source: PaymentSource('123', '副業'),
                );
  
                context.read<SalaryViewModel>().addSalary(newSalary);
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
