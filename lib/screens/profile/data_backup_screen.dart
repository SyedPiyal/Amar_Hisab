import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class DataBackupScreen extends StatefulWidget {
  const DataBackupScreen({super.key});

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen> {
  bool _autoBackup = true;
  String _frequency = 'সাপ্তাহিক';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ডাটা ব্যাকআপ',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_done_rounded,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'সব কিছু সুরক্ষিত আছে!',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'শেষ ব্যাকআপ: আজ, সকাল ১০:৩০ মিনিট',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Backup Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'এখন ব্যাকআপ নিন',
                    Icons.cloud_upload_rounded,
                    AppColors.primary,
                    () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'রিস্টোর করুন',
                    Icons.cloud_download_rounded,
                    AppColors.secondary,
                    () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Settings
            _buildSectionHeader('ব্যাকআপ সেটিংস'),
            const SizedBox(height: 16),
            _buildSettingCard(
              'অটো ব্যাকআপ',
              'ওয়াইফাই ব্যবহার করে ক্লাউড ব্যাকআপ',
              Switch(
                value: _autoBackup,
                onChanged: (val) => setState(() => _autoBackup = val),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              'ব্যাকআপ ফ্রিকোয়েন্সি',
              'আপনার ডাটা কত সময় পর পর সেভ হবে',
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _frequency,
                  style: GoogleFonts.hindSiliguri(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, Widget trailing) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.hindSiliguri(fontSize: 12),
        ),
        trailing: trailing,
      ),
    );
  }
}
