import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../transactions/provider/transaction_provider.dart';
import '../accounts/provider/account_provider.dart';
import '../../models/transaction.dart' as app_models;
import '../../models/account.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'লেনদেন বা অ্যাকাউন্ট খুঁজুন...',
              hintStyle: GoogleFonts.hindSiliguri(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.hindSiliguri(),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
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
      body: _searchQuery.isEmpty 
          ? _buildInitialState() 
          : _buildSearchResults(),
    );
  }

  Widget _buildInitialState() {
    return Column(
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
    );
  }

  Widget _buildSearchResults() {
    return Consumer2<TransactionProvider, AccountProvider>(
      builder: (context, txProvider, accProvider, _) {
        final filteredTransactions = txProvider.transactions.where((tx) {
          return tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 tx.category.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        final filteredAccounts = accProvider.accounts.where((acc) {
          return acc.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredTransactions.isEmpty && filteredAccounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 64, color: AppColors.border),
                const SizedBox(height: 16),
                Text(
                  'কোন ফলাফল পাওয়া যায়নি',
                  style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (filteredAccounts.isNotEmpty) ...[
              _buildSectionTitle('অ্যাকাউন্টসমূহ'),
              ...filteredAccounts.map((acc) => _buildAccountItem(acc)),
              const SizedBox(height: 16),
            ],
            if (filteredTransactions.isNotEmpty) ...[
              _buildSectionTitle('লেনদেনসমূহ'),
              ...filteredTransactions.map((tx) => _buildTransactionItem(tx)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAccountItem(Account account) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
        ),
        title: Text(account.name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
        subtitle: Text(account.type, style: GoogleFonts.hindSiliguri(fontSize: 12)),
        trailing: Text(
          '৳${NumberFormat('#,###.##').format(account.balance)}',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // Handle account tap if needed
        },
      ),
    );
  }

  Widget _buildTransactionItem(app_models.Transaction tx) {
    final bool isIncome = tx.type == 'Income';
    final balanceFormat = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '৳',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM, yyyy');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isIncome ? Colors.green.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: isIncome ? Colors.green : AppColors.error,
            size: 20,
          ),
        ),
        title: Text(tx.title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
        subtitle: Text('${tx.category} • ${dateFormat.format(tx.date)}', style: GoogleFonts.hindSiliguri(fontSize: 12)),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${balanceFormat.format(tx.amount)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // Handle transaction tap if needed
        },
      ),
    );
  }

  Widget _buildRecentSearchItem(String text) {
    return ListTile(
      leading: const Icon(Icons.history_rounded, size: 20, color: AppColors.textSecondary),
      title: Text(text, style: GoogleFonts.hindSiliguri(color: AppColors.textPrimary)),
      trailing: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.textSecondary),
      onTap: () {
        _searchController.text = text;
        setState(() {
          _searchQuery = text;
        });
      },
    );
  }
}
