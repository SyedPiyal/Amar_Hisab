import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../models/debt.dart';
import '../../../models/transaction.dart';
import '../../../models/account.dart';
import '../../../services/sync_service.dart';

class DebtProvider with ChangeNotifier {
  static const String _baseBoxName = 'debts';
  List<Debt> _debts = [];
  final SyncService _syncService = SyncService();

  DebtProvider() {
    loadDebts();
    _syncService.onUidChanged.listen((uid) {
      loadDebts();
    });
  }

  String get _scopedBoxName {
    final uid = _syncService.currentUid;
    return uid != null ? '${_baseBoxName}_$uid' : '${_baseBoxName}_shared';
  }

  List<Debt> get debts => _debts;
  List<Debt> get receivables => _debts.where((d) => d.type == 'Receivable').toList();
  List<Debt> get payables => _debts.where((d) => d.type == 'Payable').toList();

  double get totalReceivable => receivables.fold(0, (sum, d) => sum + d.remainingAmount);
  double get totalPayable => payables.fold(0, (sum, d) => sum + d.remainingAmount);

  Future<void> loadDebts() async {
    try {
      final box = await Hive.openBox<Debt>(_scopedBoxName);
      _debts = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading debts: $e');
    }
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
    final box = await Hive.openBox<Debt>(_scopedBoxName);
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

    if (account != null) {
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

      // Note: TransactionProvider handles its own scoping, so we use its add method if possible, 
      // but here we manually add to maintain the current logic while ensuring sync.
      final uid = _syncService.currentUid;
      final txBoxName = uid != null ? 'transactions_$uid' : 'transactions_shared';
      final txBox = await Hive.openBox<Transaction>(txBoxName);
      await txBox.add(transaction);

      if (txType == 'Income') {
        account.balance += amount;
      } else {
        account.balance -= amount;
      }
      await account.save();
      
      await _syncService.enqueueOperation('transactions', transaction.id, 'CREATE', _transactionToMap(transaction));
    }

    _debts = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    await _syncService.enqueueOperation(_baseBoxName, debt.id, 'CREATE', _debtToMap(debt));
  }

  Future<void> addPayment(Debt debt, double paymentAmount, Account account, {DateTime? date}) async {
    final now = date ?? DateTime.now();
    
    debt.remainingAmount -= paymentAmount;
    if (debt.remainingAmount <= 0) {
      debt.remainingAmount = 0;
      debt.status = 'Settled';
    }
    await debt.save();

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

    final uid = _syncService.currentUid;
    final txBoxName = uid != null ? 'transactions_$uid' : 'transactions_shared';
    final txBox = await Hive.openBox<Transaction>(txBoxName);
    await txBox.add(transaction);

    if (txType == 'Income') {
      account.balance += paymentAmount;
    } else {
      account.balance -= paymentAmount;
    }
    await account.save();

    notifyListeners();

    await _syncService.enqueueOperation(_baseBoxName, debt.id, 'UPDATE', _debtToMap(debt));
    await _syncService.enqueueOperation('transactions', transaction.id, 'CREATE', _transactionToMap(transaction));
  }

  Future<void> deleteDebt(Debt debt) async {
    final debtId = debt.id;
    await debt.delete();
    _debts.removeWhere((d) => d.id == debtId);
    notifyListeners();

    await _syncService.enqueueOperation(_baseBoxName, debtId, 'DELETE', null);
  }

  Map<String, dynamic> _debtToMap(Debt debt) {
    return {
      'id': debt.id,
      'personName': debt.personName,
      'amount': debt.amount,
      'remainingAmount': debt.remainingAmount,
      'type': debt.type,
      'date': debt.date.toIso8601String(),
      'dueDate': debt.dueDate?.toIso8601String(),
      'note': debt.note,
      'status': debt.status,
      'accountId': debt.accountId,
      'phoneNumber': debt.phoneNumber,
    };
  }

  Map<String, dynamic> _transactionToMap(Transaction tx) {
    return {
      'id': tx.id,
      'title': tx.title,
      'amount': tx.amount,
      'date': tx.date.toIso8601String(),
      'accountId': tx.accountId,
      'type': tx.type,
      'category': tx.category,
      'debtId': tx.debtId,
    };
  }
}
