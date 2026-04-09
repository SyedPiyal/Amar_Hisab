import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ScheduledTransactionsScreen extends StatelessWidget {
  const ScheduledTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'নির্ধারিত লেনদেন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildScheduledItem();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
        label: Text(
          'নতুন শিডিউল',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildScheduledItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.repeat_rounded, color: AppColors.primary),
        ),
        title: Text(
          'ইন্টারনেট বিল পরিশোধ',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'প্রতি মাসের ১০ তারিখ',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '৳ ১,২০০.০০ • ক্যাশ অ্যাকাউন্ট',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: true,
          onChanged: (val) {},
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }
}
