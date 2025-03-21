import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
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
    List<Salary> shops = _realmService.fetchAll();

    return Scaffold(
      appBar: AppBar(title: const Text('Shop List')),
      body: ListView.builder(
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          return ListTile(
            title: Text(shop.id),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _realmService.delete(shop);
                setState(() {}); // UIを更新
              },
            ),
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
                _realmService.add<Salary>(newSalary);
                setState(() {});
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
