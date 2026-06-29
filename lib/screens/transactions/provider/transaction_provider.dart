import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../models/transaction.dart';
import '../../../models/account.dart';
import '../../../providers/inventory_provider.dart';

class TransactionProvider with ChangeNotifier {
  static const String boxName = 'transactions';
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    final box = await Hive.openBox<Transaction>(boxName);
    _transactions = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(
    Transaction transaction, 
    Account account, {
    Account? creditAccount,
    InventoryProvider? inventoryProvider,
  }) async {
    final box = await Hive.openBox<Transaction>(boxName);
    await box.add(transaction);

    // Update account balance
    if (creditAccount != null) {
      creditAccount.balance -= transaction.amount;
      account.balance += transaction.amount;
      
      await creditAccount.save();
      await account.save();
    } else {
      if (transaction.type == 'Income') {
        account.balance += transaction.amount;
      } else if (transaction.type == 'Expense') {
        account.balance -= transaction.amount;
      }
      await account.save();
    }

    // Handle Inventory Stock adjustment
    if (transaction.inventoryItemId != null && 
        transaction.inventoryQuantity != null && 
        inventoryProvider != null) {
      // If it's Income (Sale), we deduct from stock
      // If it's Expense (Purchase), we add to stock
      double adjustment = 0;
      if (transaction.type == 'Income') {
        adjustment = -transaction.inventoryQuantity!;
      } else if (transaction.type == 'Expense') {
        adjustment = transaction.inventoryQuantity!;
      }
      
      if (adjustment != 0) {
        await inventoryProvider.adjustStock(transaction.inventoryItemId!, adjustment);
      }
    }

    _transactions = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransaction(
    Transaction transaction, {
    Account? account,
    Account? creditAccount,
    InventoryProvider? inventoryProvider,
  }) async {
    // 1. Revert Account Balance
    if (account != null) {
      if (creditAccount != null) {
        // Revert Transfer: Credit was deducted, Account was added
        creditAccount.balance += transaction.amount;
        account.balance -= transaction.amount;
        await creditAccount.save();
        await account.save();
      } else {
        if (transaction.type == 'Income') {
          account.balance -= transaction.amount;
        } else if (transaction.type == 'Expense') {
          account.balance += transaction.amount;
        }
        await account.save();
      }
    }

    // 2. Revert Inventory Stock
    if (transaction.inventoryItemId != null && 
        transaction.inventoryQuantity != null && 
        inventoryProvider != null) {
      // Revert Income (Sale): Add back to stock
      // Revert Expense (Purchase): Deduct from stock
      double reversalAdjustment = 0;
      if (transaction.type == 'Income') {
        reversalAdjustment = transaction.inventoryQuantity!;
      } else if (transaction.type == 'Expense') {
        reversalAdjustment = -transaction.inventoryQuantity!;
      }
      
      if (reversalAdjustment != 0) {
        await inventoryProvider.adjustStock(transaction.inventoryItemId!, reversalAdjustment);
      }
    }

    await transaction.delete();
    final box = await Hive.openBox<Transaction>(boxName);
    _transactions = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  double getMonthlySavings() {
    final now = DateTime.now();
    double income = 0;
    double expense = 0;
    
    for (var tx in _transactions) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        if (tx.type == 'Income') {
          income += tx.amount;
        } else if (tx.type == 'Expense') {
          expense += tx.amount;
        }
      }
    }
    return income - expense;
  }

  List<Transaction> get todayTopTransactions {
    final now = DateTime.now();
    final todayTxs = _transactions.where((tx) => 
      tx.date.day == now.day && 
      tx.date.month == now.month && 
      tx.date.year == now.year &&
      tx.type == 'Expense'
    ).toList();
    
    todayTxs.sort((a, b) => b.amount.compareTo(a.amount));
    return todayTxs.take(3).toList();
  }

  bool checkAnomaly(double amount, String category, String type) {
    if (type != 'Expense' || _transactions.isEmpty) return false;
    
    final categoryTxs = _transactions.where((tx) => tx.category == category && tx.type == 'Expense').toList();
    if (categoryTxs.isEmpty) return false;
    
    double total = 0;
    for (var tx in categoryTxs) {
      total += tx.amount;
    }
    double average = total / categoryTxs.length;
    
    if (average > 0 && amount > (average * 3) && amount > 500) {
      return true;
    }
    return false;
  }
}
