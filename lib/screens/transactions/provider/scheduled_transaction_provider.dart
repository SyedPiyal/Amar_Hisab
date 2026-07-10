import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../models/scheduled_transaction.dart';
import '../../../models/transaction.dart';
import '../../../models/account.dart';
import 'transaction_provider.dart';
import '../../accounts/provider/account_provider.dart';
import '../../../services/sync_service.dart';

class ScheduledTransactionProvider with ChangeNotifier {
  static const String _baseBoxName = 'scheduled_transactions';
  List<ScheduledTransaction> _schedules = [];
  final SyncService _syncService = SyncService();

  List<ScheduledTransaction> get schedules => _schedules;

  ScheduledTransactionProvider() {
    loadSchedules();
    _syncService.onUidChanged.listen((uid) {
      loadSchedules();
    });
  }

  String get _scopedBoxName {
    final uid = _syncService.currentUid;
    return uid != null ? '${_baseBoxName}_$uid' : '${_baseBoxName}_shared';
  }

  Future<void> loadSchedules() async {
    try {
      final box = await Hive.openBox<ScheduledTransaction>(_scopedBoxName);
      _schedules = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading schedules: $e');
    }
  }

  Future<void> addSchedule(ScheduledTransaction schedule) async {
    final box = await Hive.openBox<ScheduledTransaction>(_scopedBoxName);
    await box.put(schedule.id, schedule);
    _schedules = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      schedule.id,
      'CREATE',
      _scheduleToMap(schedule),
    );
  }

  Future<void> toggleSchedule(ScheduledTransaction schedule, bool isActive) async {
    schedule.isActive = isActive;
    await schedule.save();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      schedule.id,
      'UPDATE',
      _scheduleToMap(schedule),
    );
  }

  Future<void> deleteSchedule(ScheduledTransaction schedule) async {
    final scheduleId = schedule.id;
    await schedule.delete();
    _schedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      scheduleId,
      'DELETE',
      null,
    );
  }

  Future<void> processDueTransactions(
    TransactionProvider txProvider,
    AccountProvider accountProvider,
  ) async {
    final box = await Hive.openBox<ScheduledTransaction>(_scopedBoxName);
    final now = DateTime.now();
    bool updated = false;

    for (var schedule in box.values) {
      if (schedule.isActive && now.isAfter(schedule.nextDueDate)) {
        final account = accountProvider.accounts.firstWhere(
          (a) => a.id == schedule.accountId,
          orElse: () => Account(id: '', name: '', type: '', iconName: ''),
        );

        if (account.id.isNotEmpty) {
          final newTx = Transaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '${schedule.title} (শিডিউল)',
            amount: schedule.amount,
            date: now,
            accountId: schedule.accountId,
            type: schedule.type,
            category: schedule.category,
          );

          await txProvider.addTransaction(newTx, account);

          DateTime nextDate = schedule.nextDueDate;
          if (schedule.frequency == 'Daily' || schedule.frequency == 'দৈনিক') {
            nextDate = nextDate.add(const Duration(days: 1));
          } else if (schedule.frequency == 'Weekly' || schedule.frequency == 'সাপ্তাহিক') {
            nextDate = nextDate.add(const Duration(days: 7));
          } else {
            int nextMonth = nextDate.month + 1;
            int nextYear = nextDate.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            nextDate = DateTime(nextYear, nextMonth, nextDate.day);
          }

          schedule.nextDueDate = nextDate;
          await schedule.save();
          updated = true;

          await _syncService.enqueueOperation(
            _baseBoxName,
            schedule.id,
            'UPDATE',
            _scheduleToMap(schedule),
          );
        }
      }
    }

    if (updated) {
      _schedules = box.values.toList();
      notifyListeners();
    }
  }

  Map<String, dynamic> _scheduleToMap(ScheduledTransaction schedule) {
    return {
      'id': schedule.id,
      'title': schedule.title,
      'amount': schedule.amount,
      'accountId': schedule.accountId,
      'type': schedule.type,
      'category': schedule.category,
      'frequency': schedule.frequency,
      'nextDueDate': schedule.nextDueDate.toIso8601String(),
      'isActive': schedule.isActive,
    };
  }
}
