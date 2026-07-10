import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/savings_goal.dart';
import '../../../services/sync_service.dart';

class SavingsGoalProvider with ChangeNotifier {
  static const String _baseBoxName = 'savings_goals';
  List<SavingsGoal> _goals = [];
  final SyncService _syncService = SyncService();

  List<SavingsGoal> get goals => _goals;

  SavingsGoalProvider() {
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
      final box = await Hive.openBox<SavingsGoal>(_scopedBoxName);
      _goals = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing savings goals: $e');
    }
  }

  Future<void> addGoal(SavingsGoal goal) async {
    final box = await Hive.openBox<SavingsGoal>(_scopedBoxName);
    await box.put(goal.id, goal);
    _goals = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      goal.id,
      'CREATE',
      _goalToMap(goal),
    );
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await goal.save();
    final box = await Hive.openBox<SavingsGoal>(_scopedBoxName);
    _goals = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      goal.id,
      'UPDATE',
      _goalToMap(goal),
    );
  }

  Future<void> deleteGoal(SavingsGoal goal) async {
    final goalId = goal.id;
    await goal.delete();
    final box = await Hive.openBox<SavingsGoal>(_scopedBoxName);
    _goals = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      goalId,
      'DELETE',
      null,
    );
  }

  Future<void> addAmount(SavingsGoal goal, double amount) async {
    goal.currentAmount += amount;
    await goal.save();
    final box = await Hive.openBox<SavingsGoal>(_scopedBoxName);
    _goals = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
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
