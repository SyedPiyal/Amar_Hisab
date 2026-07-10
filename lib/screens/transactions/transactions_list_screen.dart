import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import 'provider/transaction_provider.dart';
import '../../models/transaction.dart' as app_models;
import 'add_transaction_screen.dart';
import '../accounts/provider/account_provider.dart';
import '../inventory/inventory_provider.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _selectedFilter = 'সবগুলো';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load transactions when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'ফিল্টার নির্বাচন করুন',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.list_rounded),
                title: Text('সবগুলো', style: GoogleFonts.hindSiliguri()),
                onTap: () {
                  setState(() => _selectedFilter = 'সবগুলো');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward_rounded, color: AppColors.success),
                title: Text('আয় (Income)', style: GoogleFonts.hindSiliguri()),
                onTap: () {
                  setState(() => _selectedFilter = 'আয়');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward_rounded, color: AppColors.error),
                title: Text('ব্যয় (Expense)', style: GoogleFonts.hindSiliguri()),
                onTap: () {
                  setState(() => _selectedFilter = 'ব্যয়');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                title: Text('ট্রান্সফার (Transfer)', style: GoogleFonts.hindSiliguri()),
                onTap: () {
                  setState(() => _selectedFilter = 'ট্রান্সফার');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'লেনদেন খুঁজুন...',
                  hintStyle: GoogleFonts.hindSiliguri(color: AppColors.textSecondary, fontSize: 16),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.hindSiliguri(),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : Text(
                'লেনদেনের তালিকা',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterOptions,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs (Chips)
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
                
                // 1. Filter by Type
                List<app_models.Transaction> filtered = allTransactions;
                if (_selectedFilter == 'আয়') {
                  filtered = filtered.where((t) => t.type == 'Income').toList();
                } else if (_selectedFilter == 'ব্যয়') {
                  filtered = filtered.where((t) => t.type == 'Expense').toList();
                } else if (_selectedFilter == 'ট্রান্সফার') {
                  filtered = filtered.where((t) => t.type == 'Transfer').toList();
                }

                // 2. Filter by Search Query
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered
                      .where((t) => t.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.border),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'কোন লেনদেন নেই' : 'কোন ফলাফল পাওয়া যায়নি',
                          style: GoogleFonts.hindSiliguri(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          ).then((_) {
            // Refresh list when returning from add screen
            if (mounted) {
              Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
            }
          });
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'নতুন লেনদেন',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
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
    bool isTransfer = tx.type == 'Transfer';
    
    final balanceFormat = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '৳ ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM, yyyy - hh:mm a');

    IconData iconData = Icons.shopping_bag_outlined;
    Color iconColor = AppColors.error;
    
    if (isIncome) {
      iconData = Icons.arrow_downward_rounded;
      iconColor = AppColors.success;
    } else if (isTransfer) {
      iconData = Icons.swap_horiz_rounded;
      iconColor = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(tx.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('মুছে ফেলুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
              content: Text('আপনি কি নিশ্চিত যে এই লেনদেনটি মুছে ফেলতে চান? এর ফলে অ্যাকাউন্ট ব্যালেন্স এবং ইনভেন্টরি স্টক (যদি থাকে) পরিবর্তিত হবে।', style: GoogleFonts.hindSiliguri()),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('হ্যাঁ', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          final txProvider = Provider.of<TransactionProvider>(context, listen: false);
          final accountProvider = Provider.of<AccountProvider>(context, listen: false);
          final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

          final account = accountProvider.accounts.firstWhere((a) => a.id == tx.accountId);
          final creditAccount = tx.creditAccountId != null 
              ? accountProvider.accounts.firstWhere((a) => a.id == tx.creditAccountId) 
              : null;

          await txProvider.deleteTransaction(
            tx,
            account: account,
            creditAccount: creditAccount,
            inventoryProvider: inventoryProvider,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('লেনদেনটি মুছে ফেলা হয়েছে এবং ব্যালেন্স সমন্বয় করা হয়েছে।')),
            );
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
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
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Text(
              '${isIncome ? '+' : (isTransfer ? '' : '-')} ${balanceFormat.format(tx.amount)}',
              style: TextStyle(
                color: isIncome ? AppColors.success : (isTransfer ? AppColors.primary : AppColors.error),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
