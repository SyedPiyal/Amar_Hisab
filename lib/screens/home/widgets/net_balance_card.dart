import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../settings/provider/settings_provider.dart';
import '../../accounts/provider/account_provider.dart';
import '../../transactions/provider/transaction_provider.dart';

class NetBalanceCard extends StatelessWidget {
  const NetBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final currencySymbol = settings.currency == 'BDT'
        ? '৳ '
        : (settings.currency == 'USD' ? '\$' : '${settings.currency} ');

    final balanceFormat = NumberFormat.currency(
      locale: settings.language == 'bn' ? 'bn_BD' : 'en_US',
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (var tx in transactionProvider.transactions) {
      if (tx.type == 'Income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'Expense') {
        totalExpense += tx.amount;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'মোট ব্যালেন্স (Net Balance)',
              style: GoogleFonts.hindSiliguri(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              balanceFormat.format(
                accountProvider.totalBalance,
              ),
              style: GoogleFonts.hindSiliguri(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceInfo(
                  'আয় (Income)',
                  balanceFormat.format(totalIncome),
                  Icons.arrow_downward_rounded,
                ),
                _buildBalanceInfo(
                  'ব্যয় (Expense)',
                  balanceFormat.format(totalExpense),
                  Icons.arrow_upward_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceInfo(
                  'নগদ (Cash)',
                  balanceFormat.format(
                    accountProvider.cashBalance,
                  ),
                  Icons.money_rounded,
                ),
                _buildBalanceInfo(
                  'ব্যাংক (Bank)',
                  balanceFormat.format(
                    accountProvider.bankBalance,
                  ),
                  Icons.food_bank_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String amount, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
