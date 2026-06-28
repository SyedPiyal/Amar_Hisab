import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'provider/debt_provider.dart';
import '../../models/debt.dart';
import 'add_debt_screen.dart';
import 'debt_details_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => Provider.of<DebtProvider>(context, listen: false).loadDebts());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'দেনা-পাওনা',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'পাওনা (Receivable)'),
            Tab(text: 'দেনা (Payable)'),
          ],
        ),
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDebtList(provider.receivables, 'Receivable'),
              _buildDebtList(provider.payables, 'Payable'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddDebtScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'নতুন এন্ট্রি',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDebtList(List<Debt> debts, String type) {
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'Receivable' ? Icons.call_received_rounded : Icons.call_made_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              type == 'Receivable' ? 'কোন পাওনা নেই' : 'কোন দেনা নেই',
              style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return MultiSelectionWidget(
       debts: debts,
       type: type,
    );
  }
}

class MultiSelectionWidget extends StatelessWidget {
  final List<Debt> debts;
  final String type;

  const MultiSelectionWidget({super.key, required this.debts, required this.type});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DebtProvider>(context);
    final total = type == 'Receivable' ? provider.totalReceivable : provider.totalPayable;

    return Column(
      children: [
        _buildSummaryCard(total, type),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              return _buildDebtItem(context, debt);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(double total, String type) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: type == 'Receivable' 
              ? [AppColors.success, AppColors.secondary] 
              : [AppColors.error, Colors.orangeAccent],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (type == 'Receivable' ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type == 'Receivable' ? 'মোট পাওনা (Receivable)' : 'মোট দেনা (Payable)',
            style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '৳ ${NumberFormat('#,##,###.##').format(total)}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem(BuildContext context, Debt debt) {
    final isSettled = debt.status == 'Settled';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      borderOnForeground: true,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.background,
                child: Text(
                  debt.personName[0].toUpperCase(),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.personName,
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: isSettled ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (debt.dueDate != null)
                      Text(
                        'তারিখ: ${DateFormat('dd MMM yyyy').format(debt.dueDate!)}',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳ ${NumberFormat('#,###').format(debt.remainingAmount)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: isSettled ? AppColors.textSecondary : (debt.type == 'Receivable' ? AppColors.success : AppColors.error),
                    ),
                  ),
                  if (isSettled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'পরিশোধিত',
                        style: GoogleFonts.hindSiliguri(fontSize: 10, color: AppColors.success),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
