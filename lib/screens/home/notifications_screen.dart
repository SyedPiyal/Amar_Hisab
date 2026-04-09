import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'নোটিফিকেশন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildNotificationItem(index);
        },
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    bool isUnread = index < 2;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 2 : 0,
      color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.7),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (index % 2 == 0 ? AppColors.primary : AppColors.secondary)
                  .withValues(alpha: 0.1),
          child: Icon(
            index % 2 == 0
                ? Icons.notifications_active_rounded
                : Icons.account_balance_rounded,
            color: index % 2 == 0 ? AppColors.primary : AppColors.secondary,
            size: 20,
          ),
        ),
        title: Text(
          index % 2 == 0
              ? 'বাজেট অতিক্রম করার সতর্কতা!'
              : 'নতুন লেনদেন শনাক্ত হয়েছে',
          style: GoogleFonts.hindSiliguri(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '১০ মিনিট আগে',
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isUnread
            ? const Icon(
                Icons.fiber_manual_record,
                color: AppColors.primary,
                size: 12,
              )
            : null,
      ),
    );
  }
}
