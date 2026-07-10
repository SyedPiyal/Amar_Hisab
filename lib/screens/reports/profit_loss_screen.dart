import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../transactions/provider/transaction_provider.dart';
import '../accounts/provider/account_provider.dart';
import '../../services/pdf_service.dart';

class ProfitLossScreen extends StatelessWidget {
  const ProfitLossScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'লাভ-ক্ষতি বিবরণী (P&L)',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final txProvider = Provider.of<TransactionProvider>(context, listen: false);
              final incomeTxs = txProvider.transactions.where((t) => t.type == 'Income').toList();
              final expenseTxs = txProvider.transactions.where((t) => t.type == 'Expense').toList();
              
              final totalIncome = incomeTxs.fold(0.0, (s, t) => s + t.amount);
              final totalExpense = expenseTxs.fold(0.0, (s, t) => s + t.amount);
              final netProfit = totalIncome - totalExpense;

              try {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF তৈরি হচ্ছে...')));
                await PdfExportService.exportProfitLoss(
                  incomeTxs: incomeTxs,
                  expenseTxs: expenseTxs,
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                  netProfit: netProfit,
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
      body: Consumer2<TransactionProvider, AccountProvider>(
        builder: (context, txProvider, accProvider, _) {
          final balanceFormat = NumberFormat.currency(
            locale: 'bn_BD',
            symbol: '৳ ',
            decimalDigits: 2,
          );

          final incomeTransactions = txProvider.transactions
              .where((t) => t.type == 'Income')
              .toList();
          final expenseTransactions = txProvider.transactions
              .where((t) => t.type == 'Expense')
              .toList();

          double totalIncome = incomeTransactions.fold(0.0, (s, t) => s + t.amount);
          double totalExpense = expenseTransactions.fold(0.0, (s, t) => s + t.amount);
          double netProfit = totalIncome - totalExpense;
          double netMargin = totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                _buildSummaryCard(
                  'নিট লাভ/ক্ষতি (Net Profit)',
                  balanceFormat.format(netProfit),
                  netProfit >= 0 ? AppColors.success : AppColors.error,
                  netMargin,
                ),
                const SizedBox(height: 32),

                // Income Section
                _buildSectionHeader('আর্থিক আয় (Operating Income)'),
                _buildTransactionList(incomeTransactions, balanceFormat, AppColors.success),
                _buildSubTotal('মোট আয়', balanceFormat.format(totalIncome)),
                
                const SizedBox(height: 48),

                // Expense Section
                _buildSectionHeader('আর্থিক ব্যয় (Operating Expenses)'),
                _buildTransactionList(expenseTransactions, balanceFormat, AppColors.error),
                _buildSubTotal('মোট ব্যয়', balanceFormat.format(totalExpense)),
                
                const SizedBox(height: 48),
                const Divider(thickness: 2),
                _buildSubTotal(
                  'নিট মুনাফা (Net Bottom Line)', 
                  balanceFormat.format(netProfit),
                  isBold: true,
                  color: netProfit >= 0 ? AppColors.success : AppColors.error,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, double margin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'মার্জিন: ${margin.toStringAsFixed(1)}%',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<dynamic> txs, NumberFormat format, Color color) {
    if (txs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('কোনও তথ্য নেই', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)),
      );
    }

    return Column(
      children: txs.map((t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                t.title,
                style: GoogleFonts.hindSiliguri(color: AppColors.textPrimary),
              ),
            ),
            Text(
              format.format(t.amount),
              style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSubTotal(String label, String amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
