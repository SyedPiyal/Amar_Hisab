import 'package:flutter/material.dart';
import '../../accounts/accounts_overview_screen.dart';
import '../../transactions/add_transaction_screen.dart';
import '../../transactions/transactions_list_screen.dart';
import '../../settings/more_screen.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AccountsOverviewScreen(),
            ),
          );
        } else if (index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        } else if (index == 3) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TransactionsListScreen(),
            ),
          );
        } else if (index == 4) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MoreScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'হোম'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'অ্যাকাউন্ট',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'যোগ করুন',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz_rounded),
          label: 'লেনদেন',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz_rounded),
          label: 'আরও',
        ),
      ],
    );
  }
}
