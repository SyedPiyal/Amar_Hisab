import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart' as app_models;

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _selectedFilter = 'সবগুলো';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'লেনদেনের তালিকা',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('সবগুলো'),
                _buildFilterChip('আয়'),
                _buildFilterChip('ব্যয়'),
                _buildFilterChip('ট্রান্সফার'),
              ],
            ),
          ),

          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final allTransactions = provider.transactions;
                List<app_models.Transaction> filtered = [];

                if (_selectedFilter == 'সবগুলো') {
                  filtered = allTransactions;
                } else if (_selectedFilter == 'আয়') {
                  filtered = allTransactions
                      .where((t) => t.type == 'Income')
                      .toList();
                } else if (_selectedFilter == 'ব্যয়') {
                  filtered = allTransactions
                      .where((t) => t.type == 'Expense')
                      .toList();
                } else {
                  filtered = allTransactions
                      .where((t) => t.type == 'Transfer')
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'কোন লেনদেন নেই',
                      style: GoogleFonts.hindSiliguri(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionCard(filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'নতুন লেনদেন',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(app_models.Transaction tx) {
    bool isIncome = tx.type == 'Income';
    final balanceFormat = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '৳ ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM, yyyy - hh:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.shopping_bag_outlined,
              color: isIncome ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          title: Text(
            tx.title,
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            dateFormat.format(tx.date),
            style: GoogleFonts.hindSiliguri(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'} ${balanceFormat.format(tx.amount)}',
            style: TextStyle(
              color: isIncome ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
