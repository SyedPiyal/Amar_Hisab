import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ক্যাটাগরি ম্যানেজমেন্ট',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryItem(
            'খাবার (Food)',
            Icons.restaurant_rounded,
            AppColors.primary,
          ),
          _buildCategoryItem(
            'পরিবহন (Transport)',
            Icons.directions_bus_rounded,
            AppColors.secondary,
          ),
          _buildCategoryItem(
            'শপিং (Shopping)',
            Icons.shopping_bag_rounded,
            Colors.purple,
          ),
          _buildCategoryItem(
            'বিল (Bills)',
            Icons.receipt_long_rounded,
            Colors.orange,
          ),
          _buildCategoryItem(
            'স্বাস্থ্য (Health)',
            Icons.medical_services_rounded,
            AppColors.success,
          ),
          _buildCategoryItem(
            'শিক্ষা (Education)',
            Icons.school_rounded,
            Colors.blue,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'নতুন ক্যাটাগরি',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.edit_outlined, size: 20),
        onTap: () {},
      ),
    );
  }
}
