import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class CategoryItem {
  final String title;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final List<CategoryItem> _categories = [
    CategoryItem(
      title: 'খাবার (Food)',
      icon: Icons.restaurant_rounded,
      color: AppColors.primary,
    ),
    CategoryItem(
      title: 'পরিবহন (Transport)',
      icon: Icons.directions_bus_rounded,
      color: AppColors.secondary,
    ),
    CategoryItem(
      title: 'শপিং (Shopping)',
      icon: Icons.shopping_bag_rounded,
      color: Colors.purple,
    ),
    CategoryItem(
      title: 'বিল (Bills)',
      icon: Icons.receipt_long_rounded,
      color: Colors.orange,
    ),
    CategoryItem(
      title: 'স্বাস্থ্য (Health)',
      icon: Icons.medical_services_rounded,
      color: AppColors.success,
    ),
    CategoryItem(
      title: 'শিক্ষা (Education)',
      icon: Icons.school_rounded,
      color: Colors.blue,
    ),
  ];

  void _addCategory() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'নতুন ক্যাটাগরি যোগ করুন',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'ক্যাটাগরির নাম লিখুন',
            ),
            style: GoogleFonts.hindSiliguri(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _categories.add(
                      CategoryItem(
                        title: controller.text.trim(),
                        icon: Icons.category_rounded,
                        color: AppColors.primary,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('যোগ করুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _editCategory(int index) {
    final TextEditingController controller = TextEditingController(text: _categories[index].title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'ক্যাটাগরি সম্পাদন করুন',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'ক্যাটাগরির নাম লিখুন',
            ),
            style: GoogleFonts.hindSiliguri(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _categories[index] = CategoryItem(
                      title: controller.text.trim(),
                      icon: _categories[index].icon,
                      color: _categories[index].color,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('নিশ্চিত করুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(int index) {
    setState(() {
      _categories.removeAt(index);
    });
  }

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final item = _categories[index];
          return _buildCategoryItem(index, item);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'নতুন ক্যাটাগরি',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index, CategoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: item.color, size: 20),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _editCategory(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: () => _deleteCategory(index),
            ),
          ],
        ),
        onTap: () => _editCategory(index),
      ),
    );
  }
}
