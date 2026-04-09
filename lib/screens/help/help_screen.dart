import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'সাহায্য ও সাপোর্ট',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'আপনার সমস্যা লিখুন...',
                prefixIcon: const Icon(Icons.search_rounded),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'সচরাচর জিজ্ঞাসিত প্রশ্ন (FAQ)',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              'কিভাবে নতুন ক্যাটাগরি যোগ করব?',
              'আপনি সেটিংস থেকে ক্যাটাগরি সেকশনে গিয়ে নতুন ক্যাটাগরি তৈরি করতে পারেন।',
            ),
            _buildFAQItem(
              'ডাবল এন্ট্রি বুককিপিং কি?',
              'এটি একটি অ্যাকাউন্টিং পদ্ধতি যেখানে প্রতিটি লেনদেনের দুটি পক্ষ থাকে।',
            ),
            _buildFAQItem(
              'রিপোর্ট কিভাবে এক্সপোর্ট করব?',
              'রিপোর্ট সেকশনে গেলে উপরে এক্সপোর্ট আইকন পাবেন।',
            ),

            const SizedBox(height: 48),
            Text(
              'যোগাযোগ করুন',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              Icons.email_outlined,
              'ইমেইল করুন',
              'support@amarhisab.com',
            ),
            _buildContactCard(
              Icons.language_rounded,
              'আমাদের ওয়েবসাইট',
              'www.amarhisab.com',
            ),
            _buildContactCard(
              Icons.facebook_rounded,
              'ফেসবুক পেজ',
              'facebook.com/amarhisab',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: GoogleFonts.hindSiliguri(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: GoogleFonts.hindSiliguri(fontSize: 14)),
        subtitle: Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      ),
    );
  }
}
