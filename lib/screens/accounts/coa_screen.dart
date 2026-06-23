import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/account_provider.dart';
import '../../models/account.dart';
import 'add_account_screen.dart';

class ChartOfAccountsScreen extends StatefulWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  State<ChartOfAccountsScreen> createState() => _ChartOfAccountsScreenState();
}

class _ChartOfAccountsScreenState extends State<ChartOfAccountsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _types = ['Assets', 'Liabilities', 'Equity', 'Income', 'Expenses'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getTypeLabelBangla(String type) {
    switch (type) {
      case 'Assets': return 'সম্পদ (Assets)';
      case 'Liabilities': return 'দায় (Liabilities)';
      case 'Equity': return 'মালিকানা (Equity)';
      case 'Income': return 'আয় (Income)';
      case 'Expenses': return 'ব্যয় (Expenses)';
      default: return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Assets': return Colors.teal;
      case 'Liabilities': return Colors.redAccent;
      case 'Equity': return Colors.indigo;
      case 'Income': return Colors.green;
      case 'Expenses': return Colors.orange;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final currencySymbol = '৳';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'চার্ট অব অ্যাকাউন্টস (COA)',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          tabs: _types.map((type) => Tab(text: _getTypeLabelBangla(type))).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'হিসাব অনুসন্ধান করুন (উদা: নগদ)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              style: GoogleFonts.hindSiliguri(),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _types.map((type) {
                final categoryAccounts = accountProvider.accounts
                    .where((a) => a.type == type)
                    .toList();

                final filteredAccounts = categoryAccounts.where((a) {
                  final matchesSearch = a.name.toLowerCase().contains(_searchQuery) ||
                      (a.code != null && a.code!.toLowerCase().contains(_searchQuery));
                  return matchesSearch;
                }).toList();

                if (filteredAccounts.isEmpty) {
                  return Center(
                    child: Text(
                      'কোন হিসাব পাওয়া যায়নি',
                      style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                    ),
                  );
                }

                // If searching, show a flat list to make it easier to find
                if (_searchQuery.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAccounts.length,
                    itemBuilder: (context, index) {
                      final acc = filteredAccounts[index];
                      return _buildAccountTile(acc, currencySymbol, 0);
                    },
                  );
                }

                // If not searching, build the hierarchy structure
                final rootAccounts = filteredAccounts.where((a) => a.parentId == null).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rootAccounts.length,
                  itemBuilder: (context, index) {
                    final root = rootAccounts[index];
                    return _buildHierarchyTree(root, filteredAccounts, currencySymbol, 0);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAccountScreen(
                initialType: _types[_tabController.index],
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'নতুন হিসাব খুলুন',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHierarchyTree(
    Account account,
    List<Account> allAccounts,
    String currencySymbol,
    double indent,
  ) {
    final children = allAccounts.where((a) => a.parentId == account.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccountTile(account, currencySymbol, indent),
        if (children.isNotEmpty)
          ...children.map((child) => _buildHierarchyTree(child, allAccounts, currencySymbol, indent + 24)),
      ],
    );
  }

  Widget _buildAccountTile(Account account, String currencySymbol, double indent) {
    final color = _getTypeColor(account.type);
    final balanceFormat = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '$currencySymbol ',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: indent),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              account.parentId == null ? Icons.account_tree_rounded : Icons.subdirectory_arrow_right_rounded,
              color: color,
            ),
          ),
          title: Row(
            children: [
              if (account.code != null && account.code!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    account.code!,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: Text(
                  account.name,
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: account.parentId == null ? FontWeight.bold : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            account.parentId == null ? 'প্রধান হিসাব (Primary Account)' : 'সহকারী হিসাব (Sub-Account)',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary),
          ),
          trailing: Text(
            balanceFormat.format(account.balance),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: account.balance >= 0 ? AppColors.textPrimary : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
