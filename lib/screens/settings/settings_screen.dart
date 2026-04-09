import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
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
          _buildToggleItem(
            'ডার্ক মোড (Dark Mode)',
            _isDarkMode,
            (val) => setState(() => _isDarkMode = val),
          ),
          _buildToggleItem(
            'নোটিফিকেশন',
            _notificationsEnabled,
            (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildToggleItem(
            'বায়োমেট্রিক লগইন',
            _biometricEnabled,
            (val) => setState(() => _biometricEnabled = val),
          ),
          const Divider(height: 32),
          _buildSelectorItem('কারেন্সি', '৳ (BDT)'),
          _buildSelectorItem('ভাষা (Language)', 'বাংলা (Bangla)'),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title, style: GoogleFonts.hindSiliguri()),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSelectorItem(String title, String value) {
    return ListTile(
      title: Text(title, style: GoogleFonts.hindSiliguri()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.hindSiliguri(color: AppColors.primary),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
