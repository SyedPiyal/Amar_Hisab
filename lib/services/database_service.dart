import 'package:hive_flutter/hive_flutter.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/app_settings.dart';
import '../models/debt.dart';
import '../models/budget.dart';
import '../models/scheduled_transaction.dart';
import '../models/savings_goal.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(DebtAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(ScheduledTransactionAdapter());
    Hive.registerAdapter(SavingsGoalAdapter());
  }
}
