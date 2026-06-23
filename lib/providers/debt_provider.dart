import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/debt.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class DebtProvider with ChangeNotifier {
  static const String boxName = 'debts';
  List<Debt> _debts = [];

  List<Debt> get debts => _debts;
  List<Debt> get receivables => _debts.where((d) => d.type == 'Receivable').toList();
  List<Debt> get payables => _debts.where((d) => d.type == 'Payable').toList();

  double get totalReceivable => receivables.fold(0, (sum, d) => sum + d.remainingAmount);
  double get totalPayable => payables.fold(0, (sum, d) => sum + d.remainingAmount);

  Future<void> loadDebts() async {
    final box = await Hive.openBox<Debt>(boxName);
    _debts = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addDebt({
    required String personName,
    required double amount,
    required String type,
    DateTime? date,
    DateTime? dueDate,
    String? note,
    Account? account,
    String? phoneNumber,
  }) async {
    final box = await Hive.openBox<Debt>(boxName);
    final debtId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = date ?? DateTime.now();

    final debt = Debt(
      id: debtId,
      personName: personName,
      amount: amount,
      remainingAmount: amount,
      type: type,
      date: now,
      dueDate: dueDate,
      note: note,
      accountId: account?.id,
      phoneNumber: phoneNumber,
    );

    await box.put(debtId, debt);

    // If account is provided, create a transaction and update balance
    if (account != null) {
      final txBox = await Hive.openBox<Transaction>('transactions');
      final txType = type == 'Receivable' ? 'Expense' : 'Income';
      
      final transaction = Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: '${type == 'Receivable' ? 'ধারে প্রদান' : 'ধার গ্রহণ'}: $personName',
        amount: amount,
        date: now,
        accountId: account.id,
        type: txType,
        category: 'Debt',
        debtId: debtId,
      );

      await txBox.add(transaction);

      if (txType == 'Income') {
        account.balance += amount;
      } else {
        account.balance -= amount;
      }
      await account.save();
    }

    _debts = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addPayment(Debt debt, double paymentAmount, Account account, {DateTime? date}) async {
    final now = date ?? DateTime.now();
    
    // Update debt
    debt.remainingAmount -= paymentAmount;
    if (debt.remainingAmount <= 0) {
      debt.remainingAmount = 0;
      debt.status = 'Settled';
    }
    await debt.save();

    // Create transaction
    final txBox = await Hive.openBox<Transaction>('transactions');
    final txType = debt.type == 'Receivable' ? 'Income' : 'Expense';
    
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'কিস্তি পরিশোধ: ${debt.personName}',
      amount: paymentAmount,
      date: now,
      accountId: account.id,
      type: txType,
      category: 'Debt Payment',
      debtId: debt.id,
    );

    await txBox.add(transaction);

    // Update account balance
    if (txType == 'Income') {
      account.balance += paymentAmount;
    } else {
      account.balance -= paymentAmount;
    }
    await account.save();

    notifyListeners();
  }

  Future<void> deleteDebt(Debt debt) async {
    await debt.delete();
    _debts.remove(debt);
    notifyListeners();
  }
}
