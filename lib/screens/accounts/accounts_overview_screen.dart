import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import 'add_account_screen.dart';
import 'provider/account_provider.dart';
import '../../models/account.dart';

class AccountsOverviewScreen extends StatelessWidget {
  const AccountsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'অ্যাকাউন্ট ওভারভিউ',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          final balanceFormat = NumberFormat.currency(
            locale: 'bn_BD',
            symbol: '৳ ',
            decimalDigits: 2,
          );

          final categories = {
            'Assets': 'সম্পদ (Assets)',
            'Liabilities': 'দায় (Liabilities)',
            'Equity': 'মালিকানাধীন মূলধন (Equity)',
            'Income': 'আয় (Income)',
            'Expenses': 'ব্যয় (Expenses)',
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: categories.entries.map((entry) {
                final categoryAccounts = provider.accounts
                    .where((a) => a.type == entry.key)
                    .toList();
                
                if (categoryAccounts.isEmpty) return const SizedBox.shrink();

                double total = categoryAccounts.fold(0.0, (s, a) => s + a.balance);
                
                // Get root accounts (no parentId)
                final rootAccounts = categoryAccounts.where((a) => a.parentId == null).toList();

                return Column(
                  children: [
                    _buildAccountCategoryCard(
                      context,
                      entry.value,
                      balanceFormat.format(total),
                      _getCategoryColor(entry.key),
                      rootAccounts.map((root) => _buildAccountHierarchy(
                        root, 
                        categoryAccounts, 
                        balanceFormat, 
                        0
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddAccountScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'Assets': return AppColors.assets;
      case 'Liabilities': return AppColors.liabilities;
      case 'Equity': return AppColors.equity;
      case 'Income': return AppColors.accent;
      case 'Expenses': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  Widget _buildAccountHierarchy(
    Account account, 
    List<Account> allAccounts, 
    NumberFormat format,
    double indent
  ) {
    final children = allAccounts.where((a) => a.parentId == account.id).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent, top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (indent > 0) 
                    Icon(Icons.subdirectory_arrow_right, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    account.name,
                    style: GoogleFonts.hindSiliguri(
                      color: AppColors.textPrimary,
                      fontWeight: indent == 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Text(
                format.format(account.balance),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (children.isNotEmpty)
          ...children.map((child) => _buildAccountHierarchy(child, allAccounts, format, indent + 20)).toList(),
      ],
    );
  }

  Widget _buildAccountCategoryCard(
    BuildContext context,
    String title,
    String total,
    Color color,
    List<Widget> items,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        title: Text(
          title,
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(
          total,
          style: GoogleFonts.hindSiliguri(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: items,
      ),
    );
  }
}
