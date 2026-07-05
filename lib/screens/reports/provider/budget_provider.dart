import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/budget.dart';
import '../../../services/sync_service.dart';

class BudgetProvider with ChangeNotifier {
  static const String boxName = 'budgets';
  late Box<Budget> _budgetBox;
  List<Budget> _budgets = [];
  final SyncService _syncService = SyncService();

  List<Budget> get budgets => _budgets;

  BudgetProvider() {
    _init();
  }

  Future<void> _init() async {
    _budgetBox = await Hive.openBox<Budget>(boxName);
    _loadBudgets();
  }

  void _loadBudgets() {
    _budgets = _budgetBox.values.toList();
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await _budgetBox.add(budget);
    _loadBudgets();

    await _syncService.enqueueOperation(
      boxName,
      budget.id,
      'CREATE',
      _budgetToMap(budget),
    );
  }

  Future<void> updateBudget(int index, Budget budget) async {
    await _budgetBox.putAt(index, budget);
    _loadBudgets();

    await _syncService.enqueueOperation(
      boxName,
      budget.id,
      'UPDATE',
      _budgetToMap(budget),
    );
  }

  Future<void> deleteBudget(int index) async {
    final budget = _budgetBox.getAt(index);
    if (budget != null) {
      final budgetId = budget.id;
      await _budgetBox.deleteAt(index);
      _loadBudgets();

      await _syncService.enqueueOperation(
        boxName,
        budgetId,
        'DELETE',
        null,
      );
    }
  }

  List<Budget> getBudgetsForMonth(int month, int year) {
    return _budgets.where((b) => b.month == month && b.year == year).toList();
  }

  Map<String, dynamic> _budgetToMap(Budget budget) {
    return {
      'id': budget.id,
      'category': budget.category,
      'limitAmount': budget.limitAmount,
      'month': budget.month,
      'year': budget.year,
    };
  }
}
