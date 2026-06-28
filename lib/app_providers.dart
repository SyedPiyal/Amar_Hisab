import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/accounts/provider/account_provider.dart';
import 'screens/transactions/provider/transaction_provider.dart';
import 'screens/auth/provider/auth_provider.dart';
import 'screens/settings/provider/settings_provider.dart';
import 'screens/debts/provider/debt_provider.dart';
import 'screens/reports/provider/budget_provider.dart';
import 'screens/transactions/provider/scheduled_transaction_provider.dart';
import 'screens/reports/provider/savings_goal_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ScheduledTransactionProvider()),
        ChangeNotifierProvider(create: (_) => SavingsGoalProvider()),
      ],
      child: child,
    );
  }
}
