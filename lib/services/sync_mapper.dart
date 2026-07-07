import '../models/account.dart';
import '../models/transaction.dart';
import '../models/debt.dart';
import '../models/budget.dart';
import '../models/scheduled_transaction.dart';
import '../models/savings_goal.dart';
import '../models/inventory_item.dart';

class SyncMapper {
  static Account mapToAccount(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      iconName: map['iconName'] ?? '',
      parentId: map['parentId'],
      code: map['code'],
    );
  }

  static Transaction mapToTransaction(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      accountId: map['accountId'] ?? '',
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      creditAccountId: map['creditAccountId'],
      debitAccountId: map['debitAccountId'],
      isSplit: map['isSplit'] ?? false,
      splitDetails: map['splitDetails'] != null ? Map<String, double>.from(map['splitDetails']) : null,
      debtId: map['debtId'],
      attachmentPaths: map['attachmentPaths'] != null ? List<String>.from(map['attachmentPaths']) : null,
      taxPercentage: (map['taxPercentage'] as num?)?.toDouble(),
      taxAmount: (map['taxAmount'] as num?)?.toDouble(),
      inventoryItemId: map['inventoryItemId'],
      inventoryQuantity: (map['inventoryQuantity'] as num?)?.toDouble(),
    );
  }

  static Debt mapToDebt(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] ?? '',
      personName: map['personName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (map['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      note: map['note'],
      accountId: map['accountId'],
      phoneNumber: map['phoneNumber'],
    )..status = map['status'] ?? 'Pending';
  }

  static Budget mapToBudget(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      limitAmount: (map['limitAmount'] as num?)?.toDouble() ?? 0.0,
      month: map['month'] ?? 1,
      year: map['year'] ?? 2024,
    );
  }

  static ScheduledTransaction mapToScheduledTransaction(Map<String, dynamic> map) {
    return ScheduledTransaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      accountId: map['accountId'] ?? '',
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      frequency: map['frequency'] ?? '',
      nextDueDate: map['nextDueDate'] != null ? DateTime.parse(map['nextDueDate']) : DateTime.now(),
    )..isActive = map['isActive'] ?? true;
  }

  static SavingsGoal mapToSavingsGoal(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
    )..currentAmount = (map['currentAmount'] as num?)?.toDouble() ?? 0.0;
  }

  static InventoryItem mapToInventoryItem(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toDouble() ?? 0.0,
    )
      ..stockQuantity = (map['stockQuantity'] as num?)?.toDouble() ?? 0.0
      ..lastUpdated = map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : DateTime.now();
  }
}
