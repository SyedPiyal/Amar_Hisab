import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../reports/reports_screen.dart';
import '../reports/budgets_screen.dart';
import '../reports/savings_goals_screen.dart';
import '../transactions/scheduled_transactions_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';
import '../help/help_screen.dart';
import '../auth/login_screen.dart';
import '../debts/debts_screen.dart';
import 'category_management_screen.dart';
import '../profile/subscription_plan_screen.dart';
import '../help/user_manual_screen.dart';
import '../../providers/auth_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'আরও অপশন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection('এনালিটিক্স', [
            _buildMenuItem(
              context,
              'রিপোর্ট ও এনালাইটিক্স',
              Icons.analytics_outlined,
              const ReportsScreen(),
            ),
            _buildMenuItem(
              context,
              'দেনা-পাওনা',
              Icons.handshake_outlined,
              const DebtsScreen(),
            ),
            _buildMenuItem(
              context,
              'বাজেট ও লিমিট',
              Icons.track_changes_rounded,
              const BudgetsScreen(),
            ),
            _buildMenuItem(
              context,
              'সঞ্চয় লক্ষ্য',
              Icons.stars_rounded,
              const SavingsGoalsScreen(),
            ),
            _buildMenuItem(
              context,
              'নির্ধারিত লেনদেন',
              Icons.event_repeat_rounded,
              const ScheduledTransactionsScreen(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildMenuSection('অ্যাকাউন্ট ও প্রোফাইল', [
            _buildMenuItem(
              context,
              'আমার প্রোফাইল',
              Icons.person_outline_rounded,
              const ProfileScreen(),
            ),
            _buildMenuItem(
              context,
              'সাবস্ক্রিপশন প্ল্যান',
              Icons.card_membership_rounded,
              const SubscriptionPlanScreen(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildMenuSection('সেটিংস ও অন্যান্য', [
            _buildMenuItem(
              context,
              'অ্যাপ সেটিংস',
              Icons.settings_outlined,
              const SettingsScreen(),
            ),
            _buildMenuItem(
              context,
              'সাহায্য ও সাপোর্ট',
              Icons.help_outline_rounded,
              const HelpScreen(),
            ),
            _buildMenuItem(
              context,
              'ক্যাটাগরি ম্যানেজমেন্ট',
              Icons.category_outlined,
              const CategoryManagementScreen(),
            ),
            _buildMenuItem(
              context,
              'ব্যবহার নির্দেশিকা',
              Icons.menu_book_rounded,
              const UserManualScreen(),
            ),
          ]),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              foregroundColor: AppColors.error,
              elevation: 0,
            ),
            child: const Text('লগ আউট'),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'ভার্সন ১.০.০',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Card(child: Column(children: items)),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget? target,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: GoogleFonts.hindSiliguri()),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () {
        if (target != null) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => target));
        }
      },
    );
  }
}
