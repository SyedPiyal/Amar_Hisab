import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

import 'models/account.dart';
import 'models/transaction.dart';
import 'models/user.dart';
import 'models/app_settings.dart';
import 'models/debt.dart';
import 'models/budget.dart';
import 'models/scheduled_transaction.dart';
import 'models/savings_goal.dart';
import 'screens/accounts/provider/account_provider.dart';
import 'screens/transactions/provider/transaction_provider.dart';
import 'screens/auth/provider/auth_provider.dart';
import 'screens/settings/provider/settings_provider.dart';
import 'screens/debts/provider/debt_provider.dart';
import 'screens/reports/provider/budget_provider.dart';
import 'screens/transactions/provider/scheduled_transaction_provider.dart';
import 'screens/reports/provider/savings_goal_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(DebtAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(ScheduledTransactionAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());

  runApp(
    MultiProvider(
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('bn'), // Bangla
      ],
      home: const SplashScreen(),
    );
  }
}
