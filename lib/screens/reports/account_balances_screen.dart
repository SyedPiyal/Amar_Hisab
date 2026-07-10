import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../accounts/provider/account_provider.dart';
import '../settings/provider/settings_provider.dart';
import '../../services/pdf_service.dart';

class AccountBalancesScreen extends StatelessWidget {
  const AccountBalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currencySymbol = settings.currency == 'BDT' ? '৳ ' : (settings.currency == 'USD' ? '\$' : '${settings.currency} ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'অ্যাকাউন্ট ব্যালেন্স বিবরণী',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final accProvider = Provider.of<AccountProvider>(context, listen: false);
              try {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF তৈরি হচ্ছে...')));
                await PdfExportService.exportAccountBalances(
                  accounts: accProvider.accounts,
                  totalBalance: accProvider.totalBalance,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
            tooltip: 'Export PDF',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          final balanceFormat = NumberFormat.currency(
            locale: settings.language == 'bn' ? 'bn_BD' : 'en_US',
            symbol: currencySymbol,
            decimalDigits: 2,
          );

          final categories = {
            'Assets': 'সম্পদ (Assets)',
            'Liabilities': 'দায় (Liabilities)',
            'Equity': 'মালিকানাধীন মূলধন (Equity)',
          };

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeader('ব্যালেন্স শীট সারসংক্ষেপ'),
              const SizedBox(height: 16),
              ...categories.entries.map((entry) {
                final categoryAccounts = provider.accounts
                    .where((acc) => acc.type == entry.key)
                    .toList();
                
                if (categoryAccounts.isEmpty) return const SizedBox.shrink();

                double total = categoryAccounts.fold(0.0, (sum, acc) => sum + acc.balance);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryRow(entry.value, balanceFormat.format(total), isHeader: true),
                    const Divider(),
                    ...categoryAccounts.map((acc) => _buildCategoryRow(acc.name, balanceFormat.format(acc.balance))),
                    const SizedBox(height: 32),
                  ],
                );
              }).toList(),
              
              const Divider(thickness: 2),
              _buildCategoryRow(
                'মোট নিট মূল্য (Net Worth)', 
                balanceFormat.format(provider.totalBalance),
                isHeader: true,
                color: AppColors.primary,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.hindSiliguri(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCategoryRow(String label, String amount, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: isHeader ? 18 : 15,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                color: color ?? (isHeader ? AppColors.textPrimary : AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: isHeader ? 18 : 15,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
