import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../transactions/provider/transaction_provider.dart';
import '../../settings/provider/settings_provider.dart';

class SavingsTracker extends StatelessWidget {
  const SavingsTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final savings = transactionProvider.getMonthlySavings();
    final goal = settingsProvider.settings.monthlySavingsGoal;
    final progress = (savings / goal).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'মাসিক সঞ্চয় লক্ষ্য',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'লক্ষ্য: ৳${NumberFormat('#,###').format(goal)}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$percent%',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'বর্তমানে: ৳${NumberFormat('#,###').format(savings)}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  savings >= goal
                      ? 'লক্ষ্য পূরণ!'
                      : 'বাকি: ৳${NumberFormat('#,###').format(goal - savings)}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    color: savings >= goal
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
