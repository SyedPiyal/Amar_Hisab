import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/savings_goal.dart';
import '../../../services/sync_service.dart';

class SavingsGoalProvider with ChangeNotifier {
  static const String boxName = 'savings_goals';
  late Box<SavingsGoal> _goalBox;
  List<SavingsGoal> _goals = [];
  final SyncService _syncService = SyncService();

  List<SavingsGoal> get goals => _goals;

  SavingsGoalProvider() {
    _init();
  }

  Future<void> _init() async {
    _goalBox = await Hive.openBox<SavingsGoal>(boxName);
    _loadGoals();
  }

  void _loadGoals() {
    _goals = _goalBox.values.toList();
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    await _goalBox.put(goal.id, goal);
    _loadGoals();

    await _syncService.enqueueOperation(
      boxName,
      goal.id,
      'CREATE',
      _goalToMap(goal),
    );
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await goal.save();
    _loadGoals();

    await _syncService.enqueueOperation(
      boxName,
      goal.id,
      'UPDATE',
      _goalToMap(goal),
    );
  }

  Future<void> deleteGoal(SavingsGoal goal) async {
    final goalId = goal.id;
    await goal.delete();
    _loadGoals();

    await _syncService.enqueueOperation(
      boxName,
      goalId,
      'DELETE',
      null,
    );
  }

  Future<void> addAmount(SavingsGoal goal, double amount) async {
    goal.currentAmount += amount;
    await goal.save();
    _loadGoals();

    await _syncService.enqueueOperation(
      boxName,
      goal.id,
      'UPDATE',
      _goalToMap(goal),
    );
  }

  Map<String, dynamic> _goalToMap(SavingsGoal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'targetDate': goal.targetDate?.toIso8601String(),
    };
  }
}
