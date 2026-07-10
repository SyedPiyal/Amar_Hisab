import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../models/account.dart';
import '../../../services/sync_service.dart';

class AccountProvider with ChangeNotifier {
  static const String _baseBoxName = 'accounts';
  List<Account> _accounts = [];
  final SyncService _syncService = SyncService();
  bool _isLoading = false;

  AccountProvider() {
    // Initial load
    loadAccounts();
    // Listen for user changes to reload data
    _syncService.onUidChanged.listen((uid) {
      loadAccounts();
    });
  }

  String get _scopedBoxName {
    final uid = _syncService.currentUid;
    return uid != null ? '${_baseBoxName}_$uid' : '${_baseBoxName}_shared';
  }

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  double get totalBalance {
    return _accounts.fold(0.0, (sum, item) => sum + item.balance);
  }

  double get cashBalance {
    return _accounts
        .where((a) =>
            a.name.toLowerCase().contains('cash') ||
            a.name.contains('নগদ'))
        .fold(0.0, (sum, item) => sum + item.balance);
  }

  double get bankBalance {
    return _accounts
        .where((a) =>
            a.name.toLowerCase().contains('bank') ||
            a.name.contains('ব্যাংক') ||
            a.name.toLowerCase().contains('account'))
        .fold(0.0, (sum, item) => sum + item.balance);
  }

  Future<void> loadAccounts() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final box = await Hive.openBox<Account>(_scopedBoxName);
      final loadedAccounts = box.values.toList();
      
      if (loadedAccounts.isEmpty) {
        await _seedDefaultAccounts();
      } else {
        _accounts = loadedAccounts;
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedDefaultAccounts() async {
    try {
      final box = await Hive.openBox<Account>(_scopedBoxName);
      final defaultAccounts = [
        Account(
          id: 'default_cash_${_syncService.currentUid}',
          name: 'নগদ (Cash)',
          type: 'Assets',
          balance: 0.0,
          iconName: 'payments',
        ),
        Account(
          id: 'default_bank_${_syncService.currentUid}',
          name: 'ব্যাংক অ্যাকাউন্ট (Bank)',
          type: 'Assets',
          balance: 0.0,
          iconName: 'account_balance',
        ),
        Account(
          id: 'default_income_${_syncService.currentUid}',
          name: 'বিক্রয় / আয় (Sales)',
          type: 'Income',
          balance: 0.0,
          iconName: 'trending_up',
        ),
        Account(
          id: 'default_expense_${_syncService.currentUid}',
          name: 'খরচ (Expenses)',
          type: 'Expenses',
          balance: 0.0,
          iconName: 'trending_down',
        ),
      ];

      final Map<String, Account> accountMap = {
        for (var acc in defaultAccounts) acc.id: acc
      };
      await box.putAll(accountMap);
      _accounts = box.values.toList();
    } catch (e) {
      debugPrint('Error seeding accounts: $e');
    }
  }

  Future<void> addAccount(Account account) async {
    final box = await Hive.openBox<Account>(_scopedBoxName);
    await box.put(account.id, account);
    _accounts = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      account.id,
      'CREATE',
      _accountToMap(account),
    );
  }

  Future<void> updateAccount(Account account) async {
    await account.save();
    final box = await Hive.openBox<Account>(_scopedBoxName);
    _accounts = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      account.id,
      'UPDATE',
      _accountToMap(account),
    );
  }

  Future<void> deleteAccount(Account account) async {
    final accountId = account.id;
    await account.delete();
    _accounts.removeWhere((a) => a.id == accountId);
    notifyListeners();

    await _syncService.enqueueOperation(
      _baseBoxName,
      accountId,
      'DELETE',
      null,
    );
  }

  Map<String, dynamic> _accountToMap(Account account) {
    return {
      'id': account.id,
      'name': account.name,
      'type': account.type,
      'balance': account.balance,
      'iconName': account.iconName,
      'parentId': account.parentId,
      'code': account.code,
    };
  }
}
