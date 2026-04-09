import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'লেনদেন বা অ্যাকাউন্ট খুঁজুন...',
              prefixIcon: const Icon(Icons.search_rounded),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'সম্প্রতি খোঁজা হয়েছে',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildRecentSearchItem('বাজার খরচ'),
          _buildRecentSearchItem('অফিস স্যালারি'),
          _buildRecentSearchItem('ইন্টারনেট বিল'),

          const Spacer(),
          // Empty State illustration for search
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.manage_search_rounded,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'আপনার প্রয়োজনীয় তথ্যটি খুঁজুন',
                  style: GoogleFonts.hindSiliguri(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String text) {
    return ListTile(
      leading: const Icon(Icons.history_rounded, size: 20),
      title: Text(text, style: GoogleFonts.hindSiliguri()),
      trailing: const Icon(Icons.north_west_rounded, size: 16),
      onTap: () {},
    );
  }
}
