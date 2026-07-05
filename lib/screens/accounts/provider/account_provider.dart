import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../models/account.dart';
import '../../../services/sync_service.dart';

class AccountProvider with ChangeNotifier {
  static const String boxName = 'accounts';
  List<Account> _accounts = [];
  final SyncService _syncService = SyncService();

  List<Account> get accounts => _accounts;

  double get totalBalance {
    return _accounts.fold(0.0, (sum, item) => sum + item.balance);
  }

  double get cashBalance {
    return _accounts
        .where((a) => a.name.contains('Cash') || a.name.contains('নগদ'))
        .fold(0.0, (sum, item) => sum + item.balance);
  }

  double get bankBalance {
    return _accounts
        .where((a) => a.name.contains('Bank') || a.name.contains('ব্যাংক'))
        .fold(0.0, (sum, item) => sum + item.balance);
  }

  Future<void> loadAccounts() async {
    final box = await Hive.openBox<Account>(boxName);
    _accounts = box.values.toList();
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    final box = await Hive.openBox<Account>(boxName);
    await box.put(account.id, account);
    _accounts = box.values.toList();
    notifyListeners();

    await _syncService.enqueueOperation(
      boxName,
      account.id,
      'CREATE',
      _accountToMap(account),
    );
  }

  Future<void> updateAccount(Account account) async {
    await account.save();
    notifyListeners();

    await _syncService.enqueueOperation(
      boxName,
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
      boxName,
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
