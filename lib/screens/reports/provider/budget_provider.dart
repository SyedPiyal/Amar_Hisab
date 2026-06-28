import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/budget.dart';

class BudgetProvider with ChangeNotifier {
  late Box<Budget> _budgetBox;
  List<Budget> _budgets = [];

  List<Budget> get budgets => _budgets;

  BudgetProvider() {
    _init();
  }

  Future<void> _init() async {
    _budgetBox = await Hive.openBox<Budget>('budgets');
    _loadBudgets();
  }

  void _loadBudgets() {
    _budgets = _budgetBox.values.toList();
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await _budgetBox.add(budget);
    _loadBudgets();
  }

  Future<void> updateBudget(int index, Budget budget) async {
    await _budgetBox.putAt(index, budget);
    _loadBudgets();
  }

  Future<void> deleteBudget(int index) async {
    await _budgetBox.deleteAt(index);
    _loadBudgets();
  }

  List<Budget> getBudgetsForMonth(int month, int year) {
    return _budgets.where((b) => b.month == month && b.year == year).toList();
  }
}
