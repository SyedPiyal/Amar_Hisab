import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/savings_goal.dart';

class SavingsGoalProvider with ChangeNotifier {
  late Box<SavingsGoal> _goalBox;
  List<SavingsGoal> _goals = [];

  List<SavingsGoal> get goals => _goals;

  SavingsGoalProvider() {
    _init();
  }

  Future<void> _init() async {
    _goalBox = await Hive.openBox<SavingsGoal>('savings_goals');
    _loadGoals();
  }

  void _loadGoals() {
    _goals = _goalBox.values.toList();
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    await _goalBox.put(goal.id, goal);
    _loadGoals();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await goal.save();
    _loadGoals();
  }

  Future<void> deleteGoal(SavingsGoal goal) async {
    await goal.delete();
    _loadGoals();
  }

  Future<void> addAmount(SavingsGoal goal, double amount) async {
    goal.currentAmount += amount;
    await goal.save();
    _loadGoals();
  }
}
