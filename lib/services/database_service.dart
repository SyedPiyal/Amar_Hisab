import 'package:hive_flutter/hive_flutter.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/app_settings.dart';
import '../models/debt.dart';
import '../models/budget.dart';
import '../models/scheduled_transaction.dart';
import '../models/savings_goal.dart';
import '../models/inventory_item.dart';
import '../models/billing/product.dart';
import '../models/billing/shop.dart';
import '../models/sync_operation.dart';

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
    Hive.registerAdapter(InventoryItemAdapter());
    Hive.registerAdapter(SyncOperationAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(ShopAdapter());

    await Hive.openBox<Product>('products');
    await Hive.openBox<Shop>('shop');
    // Open settings box with correct type to match SettingsProvider
    await Hive.openBox<AppSettings>('settings');
    
    // Open sync queue box at startup to ensure it's always ready
    await Hive.openBox<SyncOperation>('sync_queue');
  }
}
