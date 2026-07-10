import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/budget.dart';
import '../../../services/sync_service.dart';

class BudgetProvider with ChangeNotifier {
  static const String _baseBoxName = 'budgets';
  List<Budget> _budgets = [];
  final SyncService _syncService = SyncService();

  List<Budget> get budgets => _budgets;

  BudgetProvider() {
    _init();
    _syncService.onUidChanged.listen((uid) {
      _init();
    });
  }

  String get _scopedBoxName {
    final uid = _syncService.currentUid;
    return uid != null ? '${_baseBoxName}_$uid' : '${_baseBoxName}_shared';
  }

  Future<void> _init() async {
    try {
      final box = await Hive.openBox<Budget>(_scopedBoxName);
      _budgets = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing budgets: $e');
    }
  }

  Future<void> addBudget(Budget budget) async {
    final box = await Hive.openBox<Budget>(_scopedBoxName);
    await box.add(budget);
    _budgets = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      budget.id,
      'CREATE',
      _budgetToMap(budget),
    );
  }

  Future<void> updateBudget(int index, Budget budget) async {
    final box = await Hive.openBox<Budget>(_scopedBoxName);
    await box.putAt(index, budget);
    _budgets = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      budget.id,
      'UPDATE',
      _budgetToMap(budget),
    );
  }

  Future<void> deleteBudget(int index) async {
    final box = await Hive.openBox<Budget>(_scopedBoxName);
    final budget = box.getAt(index);
    if (budget != null) {
      final budgetId = budget.id;
      await box.deleteAt(index);
      _budgets = box.values.toList();
      notifyListeners();

      await _syncService.enqueueOperation(
        _baseBoxName,
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
