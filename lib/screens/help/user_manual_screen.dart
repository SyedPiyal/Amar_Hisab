import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ব্যবহার নির্দেশিকা',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 32),
          _buildManualSection(
            title: 'শুরু করা',
            icon: Icons.rocket_launch_rounded,
            steps: [
              'প্রথমবার অ্যাপ খুললে আপনার মুদ্রার ধরণ (যেমন: BDT) এবং ভাষা নির্বাচন করুন।',
              'আপনার ক্যাশ বক্স এবং ব্যাংক ব্যালেন্স এর প্রারম্ভিক স্থিতি যোগ করুন।',
              'সিম্পল বা অ্যাডভান্সড মোড এর মধ্যে থেকে যেকোনো একটি বেছে নিন।',
            ],
          ),
          _buildManualSection(
            title: 'লেনদেন যোগ করা',
            icon: Icons.add_circle_outline_rounded,
            steps: [
              'ড্যাশবোর্ড নিচের "যোগ করুন" বাটনে ক্লিক করুন।',
              'লেনদেনের ধরণ (আয় বা ব্যয়) নির্বাচন করুন।',
              'টাকার পরিমাণ এবং লেনদেনের জন্য ক্যাটাগরি বেছে নিন।',
              'ভবিষ্যতের জন্য লেনদেন শিডিউল করতে "Scheduled" অপশনটি ব্যবহার করতে পারেন।',
            ],
          ),
          _buildManualSection(
            title: 'এআই অ্যাসিস্ট্যান্ট (AI Chat)',
            icon: Icons.auto_awesome_rounded,
            steps: [
              'নিচের নেভিগেশন বার থেকে "এআই অ্যাসিস্ট্যান্ট" বাটনে ক্লিক করুন।',
              'আপনার লেনদেন বা রিপোর্ট সম্পর্কে বাংলায় কথা বলুন বা টেক্সট লিখুন।',
              'এআই স্বয়ংক্রিয়ভাবে আপনার জন্য লেনদেন যোগ করতে বা আর্থিক সামারি প্রদান করতে সক্ষম।',
            ],
          ),
          _buildManualSection(
            title: 'ভেন্ডর ও ইনভেন্টরি',
            icon: Icons.inventory_2_rounded,
            steps: [
              'আপনার নিয়মিত সরবরাহকারী বা ভেন্ডরদের তালিকা তৈরি করুন।',
              'দোকানের পণ্য বা ইনভেন্টরি আইটেম যোগ করুন এবং স্টক ম্যানেজ করুন।',
              'ভেন্ডরদের সাথে লেনদেন এবং বকেয়া হিসাব আলাদাভাবে ট্র্যাক করুন।',
            ],
          ),
          _buildManualSection(
            title: 'পিওএস (POS) সিস্টেম',
            icon: Icons.point_of_sale_rounded,
            steps: [
              '"পিওএস" সেকশন থেকে খুব সহজে কাস্টমারের জন্য ইনভয়েস তৈরি করুন।',
              'বারকোড স্ক্যানার বা সার্চ অপশন ব্যবহার করে দ্রুত পণ্য নির্বাচন করুন।',
              'বিক্রয় শেষে প্রিন্টার দিয়ে রশিদ প্রিন্ট করুন ।',
            ],
          ),
          _buildManualSection(
            title: 'অ্যাকাউন্ট ম্যানেজমেন্ট',
            icon: Icons.account_balance_wallet_rounded,
            steps: [
              'আপনার একাধিক ক্যাশ বক্স বা ব্যাংক অ্যাকাউন্ট আলাদা আলাদা ভাবে ট্র্যাক করতে পারেন।',
              '"অ্যাকাউন্ট" সেকশন থেকে নতুন কোনো অ্যাকাউন্ট বা ক্যাশ বক্স যোগ করুন।',
              'এক অ্যাকাউন্ট থেকে অন্য অ্যাকাউন্টে টাকা স্থানান্তরের জন্য "Transfer" অপশনটি ব্যবহার করুন।',
            ],
          ),
          _buildManualSection(
            title: 'বাজেট ও রিপোর্ট',
            icon: Icons.analytics_rounded,
            steps: [
              'নির্দিষ্ট ক্যাটাগরির জন্য বাজেট সেট করে আপনার অতিরিক্ত ব্যয় নিয়ন্ত্রণ করুন।',
              'সাপ্তাহিক, মাসিক বা বাৎসরিক ডিটেইলড রিপোর্ট পিডিএফ আকারে ডাউনলোড করুন।',
              'আয় ও ব্যয়ের গ্রাফ দেখে আপনার আর্থিক অবস্থা সহজে মূল্যায়ন করুন।',
            ],
          ),
          const SizedBox(height: 48),
          // _buildHelpCard(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'আমার হিসাব ব্যবহার করুন খুব সহজে!',
            style: GoogleFonts.hindSiliguri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'নিচের নির্দেশিকাগুলো অনুসরণ করে আপনি খুব সহজেই আপনার ব্যক্তিগত বা ব্যবসায়িক হিসাব পরিচালনা করতে পারবেন।',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualSection({
    required String title,
    required IconData icon,
    required List<String> steps,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            int idx = entry.key;
            String text = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
