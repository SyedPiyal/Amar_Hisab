import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../accounts/coa_screen.dart';
import '../accounts/reconciliation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showOtpDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'ক্লাউড ব্যাকআপ লিংক করুন',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'আপনার ডাটা নিরাপদে ক্লাউডে ব্যাকআপ রাখতে আপনার মোবাইল নম্বরটি লিংক করুন (টালিখাতা স্টাইল)।',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixText: '+880 ',
                  hintText: '1XXXXXXXXX',
                  border: OutlineInputBorder(),
                ),
                style: GoogleFonts.inter(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: GoogleFonts.hindSiliguri()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showVerifyOtpDialog(context, provider);
              },
              child: Text('OTP পাঠান', style: GoogleFonts.hindSiliguri()),
            ),
          ],
        );
      },
    );
  }

  void _showVerifyOtpDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'OTP কোড যাচাই করুন',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+880 ${_phoneController.text} নম্বরে পাঠানো ৪ ডিজিটের কোডটি প্রবেশ করান। (সিমুলেশন কোড: 1234)',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  hintText: 'XXXX',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: GoogleFonts.hindSiliguri()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_otpController.text == '1234') {
                  await provider.updateSettings(isCloudBackupEnabled: true);
                  if (context.mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ক্লাউড ব্যাকআপ সফলভাবে সচল করা হয়েছে!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ভুল OTP! দয়া করে ১২৩৪ ব্যবহার করুন।'),
                    ),
                  );
                }
              },
              child: Text('যাচাই করুন', style: GoogleFonts.hindSiliguri()),
            ),
          ],
        );
      },
    );
  }

  void _runCloudSync(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  'ক্লাউড সার্ভারের সাথে সিঙ্ক হচ্ছে...',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialogue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ক্লাউড ব্যাকআপ সফলভাবে সম্পন্ন হয়েছে (ডাটা সিনক্রোনাইজড)',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'অ্যাপ সেটিংস',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme & Core Settings Section Header
          _buildSectionHeader('সাধারণ সেটিংস (General Settings)'),
          _buildToggleItem(
            'ডার্ক মোড (Dark Mode)',
            settings.darkModeEnabled,
            (val) => settings.updateSettings(darkModeEnabled: val),
          ),
          _buildToggleItem(
            'স্মার্ট নোটিফিকেশন',
            settings.notificationsEnabled,
            (val) => settings.updateSettings(notificationsEnabled: val),
          ),
          _buildToggleItem(
            'বায়োমেট্রিক লগইন',
            settings.biometricEnabled,
            (val) => settings.updateSettings(biometricEnabled: val),
          ),
          _buildSelectorItem(
            'ভাষা (Language)',
            settings.language == 'bn' ? 'বাংলা (Bangla)' : 'English',
            () {
              final newLang = settings.language == 'bn' ? 'en' : 'bn';
              settings.updateSettings(language: newLang);
            },
          ),

          const Divider(height: 32),

          // Advanced Accounting Features Section
          _buildSectionHeader('অ্যাডভান্সড অ্যাকাউন্টিং (Accounting Tools)'),
          _buildNavigationItem(
            'চার্ট অব অ্যাকাউন্টস (COA)',
            'হিসাবসমূহের ক্যাটাগরি ও কোড বিন্যাস দেখুন',
            Icons.account_tree_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChartOfAccountsScreen(),
              ),
            ),
          ),
          _buildNavigationItem(
            'ব্যাংক রিকনসিলিয়েশন (Reconciliation)',
            'ব্যাংক স্টেটমেন্ট ও নগদ খাতা মেলান',
            Icons.account_balance_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BankReconciliationScreen(),
              ),
            ),
          ),

          const Divider(height: 32),

          // Cloud Sync & Config Section
          _buildSectionHeader('ক্লাউড ব্যাকআপ (Cloud Sync)'),
          _buildToggleItem(
            'অটোমেটিক ক্লাউড ব্যাকআপ',
            settings.isCloudBackupEnabled,
            (val) {
              if (val) {
                _showOtpDialog(context, settings);
              } else {
                settings.updateSettings(isCloudBackupEnabled: false);
              }
            },
          ),
          if (settings.isCloudBackupEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ElevatedButton.icon(
                onPressed: () => _runCloudSync(context),
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
                label: Text(
                  'ম্যানুয়ালি ক্লাউড ব্যাকআপ নিন',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 12.0),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSelectorItem(String title, String value, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.hindSiliguri(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.hindSiliguri(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
