import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../auth/provider/auth_provider.dart';
import 'subscription_plan_screen.dart';
import 'personal_info_screen.dart';
import 'security_password_screen.dart';
import 'payment_methods_screen.dart';
import 'data_backup_screen.dart';
import 'printer_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'প্রোফাইল',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Head Profile Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.currentUser;
                final initial = (user?.name != null && user!.name.isNotEmpty)
                    ? user.name[0].toUpperCase()
                    : '?';

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initial,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'অজানা ব্যবহারকারী',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user?.email ?? 'জানা নেই',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Subscription Card
            // _buildSubscriptionCard(context),
            const SizedBox(height: 32),

            // Profile Actions
            _buildProfileAction(
              context,
              'ব্যক্তিগত তথ্য',
              Icons.badge_outlined,
              const PersonalInfoScreen(),
            ),
            _buildProfileAction(
              context,
              'নিরাপত্তা ও পাসওয়ার্ড',
              Icons.security_outlined,
              const SecurityPasswordScreen(),
            ),
            // _buildProfileAction(
            //   context,
            //   'প্রিন্টার সেটিংস',
            //   Icons.print_outlined,
            //   const PrinterSettingsScreen(),
            // ),
            // _buildProfileAction(
            //   context,
            //   'পেমেন্ট মেথড',
            //   Icons.payments_outlined,
            //   const PaymentMethodScreen(),
            // ),
            // _buildProfileAction(
            //   context,
            //   'ডাটা ব্যাকআপ',
            //   Icons.cloud_upload_outlined,
            //   const DataBackupScreen(),
            // ),

            // const SizedBox(height: 48),
            // TextButton(
            //   onPressed: () {},
            //   child: Text(
            //     'অ্যাকাউন্ট মুছে ফেলুন',
            //     style: GoogleFonts.hindSiliguri(color: AppColors.error),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
                    'বর্তমান প্ল্যান',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Pro (প্রো)',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'মেয়াদ শেষ হবে: ১৫ দিন পর',
                style: GoogleFonts.hindSiliguri(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlanScreen(),
                    ),
                  );
                },
                child: const Text(
                  'রিনিউ করুন',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAction(
    BuildContext context,
    String title,
    IconData icon,
    Widget target,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: GoogleFonts.hindSiliguri()),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => target),
            );
          },
        ),
      ),
    );
  }
}
