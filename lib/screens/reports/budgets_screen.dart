import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBudgetCard(
            'বাজার খরচ (Grocery)',
            '৳ ৮,০০০ / ১০,০০০',
            0.8,
            AppColors.primary,
          ),
          _buildBudgetCard(
            'বিনোদন (Entertainment)',
            '৳ ৩,৫০০ / ৩,০০০',
            1.16,
            AppColors.error,
          ),
          _buildBudgetCard(
            'যাতায়াত (Transport)',
            '৳ ২,২০০ / ৫,০০০',
            0.44,
            AppColors.success,
          ),
          _buildBudgetCard(
            'অন্যান্য (Others)',
            '৳ ১,০০ / ২,০০০',
            0.5,
            AppColors.secondary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: Text(
          'নতুন বাজেট',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    String title,
    String amount,
    double progress,
    Color color,
  ) {
    bool isOver = progress > 1.0;
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
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                ),
                Text(
                  isOver ? 'লিমিট অতিক্রম!' : 'বাকি আছে',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10,
                    color: isOver ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}
