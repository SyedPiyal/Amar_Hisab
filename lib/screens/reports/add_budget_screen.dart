import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/budget.dart';
import '../../providers/budget_provider.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'বাজার';
  final List<String> _categories = ['বাজার', 'খাবার', 'যাতায়াত', 'মেডিসিন', 'বিনোদন', 'অন্যান্য'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক পরিমাণ দিন')),
      );
      return;
    }

    final now = DateTime.now();
    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      limitAmount: amount,
      month: now.month,
      year: now.year,
    );

    Provider.of<BudgetProvider>(context, listen: false).addBudget(budget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'নতুন বাজেট যোগ করুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ক্যাটাগরি নির্ধারণ করুন',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 24),
            Text(
              'মাসিক লিমিট (টাকা)',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '৳ ০.০০',
                prefixIcon: Icon(Icons.money_rounded),
              ),
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveBudget,
                child: Text(
                  'বাজেট সংরক্ষণ করুন',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
