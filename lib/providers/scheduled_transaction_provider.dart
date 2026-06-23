import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/scheduled_transaction.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import './transaction_provider.dart';
import './account_provider.dart';

class ScheduledTransactionProvider with ChangeNotifier {
  static const String boxName = 'scheduled_transactions';
  List<ScheduledTransaction> _schedules = [];

  List<ScheduledTransaction> get schedules => _schedules;

  Future<void> loadSchedules() async {
    final box = await Hive.openBox<ScheduledTransaction>(boxName);
    _schedules = box.values.toList();
    notifyListeners();
  }

  Future<void> addSchedule(ScheduledTransaction schedule) async {
    final box = await Hive.openBox<ScheduledTransaction>(boxName);
    await box.put(schedule.id, schedule);
    _schedules = box.values.toList();
    notifyListeners();
  }

  Future<void> toggleSchedule(ScheduledTransaction schedule, bool isActive) async {
    schedule.isActive = isActive;
    await schedule.save();
    notifyListeners();
  }

  Future<void> deleteSchedule(ScheduledTransaction schedule) async {
    await schedule.delete();
    _schedules.remove(schedule);
    notifyListeners();
  }

  Future<void> processDueTransactions(
    TransactionProvider txProvider,
    AccountProvider accountProvider,
  ) async {
    final box = await Hive.openBox<ScheduledTransaction>(boxName);
    final now = DateTime.now();
    bool updated = false;

    for (var schedule in box.values) {
      if (schedule.isActive && now.isAfter(schedule.nextDueDate)) {
        // Find matching account
        final account = accountProvider.accounts.firstWhere(
          (a) => a.id == schedule.accountId,
          orElse: () => Account(id: '', name: '', type: '', iconName: ''),
        );

        if (account.id.isNotEmpty) {
          // Trigger the transaction insertion
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

          // Update next due date based on frequency
          DateTime nextDate = schedule.nextDueDate;
          if (schedule.frequency == 'Daily' || schedule.frequency == 'দৈনিক') {
            nextDate = nextDate.add(const Duration(days: 1));
          } else if (schedule.frequency == 'Weekly' || schedule.frequency == 'সাপ্তাহিক') {
            nextDate = nextDate.add(const Duration(days: 7));
          } else {
            // Monthly
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
        }
      }
    }

    if (updated) {
      _schedules = box.values.toList();
      notifyListeners();
    }
  }
}
