import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import 'profit_loss_screen.dart';
import 'account_balances_screen.dart';

import '../../services/export_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'মাসিক';

  final List<String> _periods = ['সাপ্তাহিক', 'মাসিক', 'বার্ষিক', 'কাস্টম'];

  List<Transaction> _getFilteredTransactions(List<Transaction> allTransactions) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'সাপ্তাহিক':
        final weekAgo = now.subtract(const Duration(days: 7));
        return allTransactions.where((t) => t.date.isAfter(weekAgo)).toList();
      case 'মাসিক':
        return allTransactions
            .where((t) => t.date.month == now.month && t.date.year == now.year)
            .toList();
      case 'বার্ষিক':
        return allTransactions.where((t) => t.date.year == now.year).toList();
      default:
        return allTransactions;
    }
  }

  String _getChartTitle() {
    switch (_selectedPeriod) {
      case 'সাপ্তাহিক':
        return 'সাপ্তাহিক খরচ';
      case 'মাসিক':
        return 'মাসিক খরচ';
      case 'বার্ষিক':
        return 'বার্ষিক খরচ';
      default:
        return 'মোট খরচ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'রিপোর্ট ও এনালাইটিক্স',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final txProvider =
                  Provider.of<TransactionProvider>(context, listen: false);
              final path = await ExportService.exportTransactionsToCsv(
                txProvider.transactions,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV এক্সপোর্ট করা হয়েছে: $path')),
                );
              }
            },
            icon: const Icon(
              Icons.file_download_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Export CSV',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // P&L Summary Card
            GestureDetector(
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfitLossScreen(),
                    ),
                  ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'লাভ-ক্ষতি বিবরণী',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'আপনার আয়ের নিখুঁত হিসাব দেখুন',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Account Balances Card
            GestureDetector(
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AccountBalancesScreen(),
                    ),
                  ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'অ্যাকাউন্ট ব্যালেন্স বিবরণী',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'আপনার সকল অ্যাকাউন্টের বর্তমান অবস্থা',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Time Range Toggle
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _periods.map((period) {
                      return _buildPeriodChip(period, _selectedPeriod == period);
                    }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Spending Bar Chart
            Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                final filteredTxs = _getFilteredTransactions(provider.transactions);
                final expenses = filteredTxs.where((t) => t.type == 'Expense').toList();

                return _buildReportCard(
                  _getChartTitle(),
                  '$_selectedPeriod সময়ের ব্যয়ের ট্রেন্ড',
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: expenses.isEmpty 
                        ? Center(child: Text('কোন তথ্য নেই', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)))
                        : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: expenses.fold(0.0, (max, e) => e.amount > max ? e.amount : max) * 1.2,
                            barGroups: List.generate(expenses.length > 7 ? 7 : expenses.length, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: expenses[index].amount,
                                    color: AppColors.primary,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                            titlesData: const FlTitlesData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Category Breakdown Pie Chart
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final filteredTxs = _getFilteredTransactions(provider.transactions);
                final expenses = filteredTxs.where((t) => t.type == 'Expense').toList();

                return _buildReportCard(
                  'ক্যাটাগরি ব্রেকডাউন',
                  '$_selectedPeriod সময়ের ব্যয়ের বিভাজন',
                  expenses.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text('কোন তথ্য নেই', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary))),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 32),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 40,
                                  sections: _getSections(expenses),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            ..._buildCategoryStats(expenses),
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Trend Line Chart (Kept static as per original style but under report card)
            _buildReportCard(
              'লেনদেন ট্রেন্ড',
              'Transaction Trend Overview',
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(1, 1),
                          FlSpot(2, 4),
                          FlSpot(3, 2),
                          FlSpot(4, 5),
                          FlSpot(5, 3),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections(List<Transaction> expenses) {
    Map<String, double> categorySums = {};
    for (var expense in expenses) {
      categorySums[expense.title] = (categorySums[expense.title] ?? 0) + expense.amount;
    }
    double total = expenses.fold(0, (sum, e) => sum + e.amount);

    List<Color> colors = [AppColors.primary, AppColors.secondary, AppColors.accent, Colors.orange, Colors.purple];
    int index = 0;

    return categorySums.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${((entry.value / total) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<Widget> _buildCategoryStats(List<Transaction> expenses) {
    Map<String, double> categorySums = {};
    for (var expense in expenses) {
      categorySums[expense.title] = (categorySums[expense.title] ?? 0) + expense.amount;
    }
    double total = expenses.fold(0, (sum, e) => sum + e.amount);
    
    List<Color> colors = [AppColors.primary, AppColors.secondary, AppColors.accent, Colors.orange, Colors.purple];
    int index = 0;

    return categorySums.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return _buildCategoryStat(entry.key, '${((entry.value / total) * 100).toStringAsFixed(1)}%', color);
    }).toList();
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStat(String name, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(name, style: GoogleFonts.hindSiliguri()),
            ],
          ),
          Text(percentage, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
