import 'package:flutter/material.dart';
import 'package:salary/repository/realm_repository.dart';
import '../models/salary.dart';

class SalaryViewModel extends ChangeNotifier {
  final RealmRepository _repository;
  List<Salary> salaries = [];

  SalaryViewModel(this._repository) {
    fetchSalaries();
  }

  void fetchSalaries() {
    salaries = _repository.fetchAll<Salary>() ?? [];
    notifyListeners();
  }

  void addSalary(Salary salary) {
    _repository.add<Salary>(salary);
    fetchSalaries(); // 更新
  }
}
