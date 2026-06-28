import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../models/account.dart';

class AccountProvider with ChangeNotifier {
  static const String boxName = 'accounts';
  List<Account> _accounts = [];

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
  }

  Future<void> updateAccount(Account account) async {
    await account.save();
    notifyListeners();
  }

  Future<void> deleteAccount(Account account) async {
    await account.delete();
    _accounts.removeWhere((a) => a.id == account.id);
    notifyListeners();
  }
}
