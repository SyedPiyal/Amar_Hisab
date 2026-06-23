import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import 'add_budget_screen.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'বাজেট ও লিমিট',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<BudgetProvider, TransactionProvider>(
        builder: (context, budgetProvider, txProvider, _) {
          final now = DateTime.now();
          final budgets = budgetProvider.getBudgetsForMonth(now.month, now.year);

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'কোন বাজেট সেট করা নেই',
                    style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              // Calculate spent amount for this category in the current month
              double spent = 0;
              for (var tx in txProvider.transactions) {
                if (tx.date.month == budget.month && 
                    tx.date.year == budget.year && 
                    tx.category == budget.category &&
                    tx.type == 'Expense') {
                  spent += tx.amount;
                }
              }

              return _buildBudgetCard(context, budget.category, spent, budget.limitAmount);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: Text(
          'নতুন বাজেট',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, String title, double spent, double limit) {
    final progress = (spent / limit).clamp(0.0, 1.2);
    final isOver = spent > limit;
    final isWarning = spent >= (limit * 0.8) && spent <= limit;
    
    Color progressColor = AppColors.primary;
    if (isOver) {
      progressColor = AppColors.error;
    } else if (isWarning) {
      progressColor = Colors.orange;
    }

    final format = NumberFormat.currency(locale: 'bn_BD', symbol: '৳', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (isOver)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'লিমিট অতিক্রম!',
                      style: GoogleFonts.hindSiliguri(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (isWarning)
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'সতর্কতা: ৮০% পূর্ণ',
                      style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${format.format(spent)} / ${format.format(limit)}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: progressColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (spent / limit).clamp(0.0, 1.0),
                backgroundColor: progressColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
