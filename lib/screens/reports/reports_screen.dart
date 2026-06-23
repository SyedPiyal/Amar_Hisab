import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('CSV এক্সপোর্ট করা হয়েছে: $path')),
              );
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
                expenses.sort((a, b) => a.date.compareTo(b.date));
                final chartData = expenses.length > 7 ? expenses.sublist(expenses.length - 7) : expenses;

                return _buildReportCard(
                  _getChartTitle(),
                  '$_selectedPeriod সময়ের ব্যয়ের ট্রেন্ড',
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: chartData.isEmpty 
                        ? Center(child: Text('কোন তথ্য নেই', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)))
                        : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: chartData.fold(0.0, (max, e) => e.amount > max ? e.amount : max) * 1.2,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => AppColors.primary.withValues(alpha: 0.9),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${chartData[groupIndex].category}\n',
                                    GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: rod.toY.toStringAsFixed(0),
                                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            barGroups: List.generate(chartData.length, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: chartData[index].amount,
                                    color: AppColors.primary,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < chartData.length) {
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Text(
                                          DateFormat('dd/MM').format(chartData[index].date),
                                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const SizedBox();
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        value >= 1000 
                                          ? '${(value / 1000).toStringAsFixed(1)}k' 
                                          : value.toInt().toString(),
                                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
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

            // Transaction Trend Section
            Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                return _buildReportCard(
                  'লেনদেন ট্রেন্ড',
                  '$_selectedPeriod সময়ের আয় ও ব্যয়ের ট্রেন্ড',
                  _buildTrendChart(provider.transactions),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<Transaction> transactions) {
    final filteredTxs = _getFilteredTransactions(transactions);

    // Grouping by date
    Map<DateTime, double> incomeMap = {};
    Map<DateTime, double> expenseMap = {};

    for (var tx in filteredTxs) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (tx.type == 'Income') {
        incomeMap[date] = (incomeMap[date] ?? 0) + tx.amount;
      } else if (tx.type == 'Expense') {
        expenseMap[date] = (expenseMap[date] ?? 0) + tx.amount;
      }
    }

    // Get all unique dates and sort them
    Set<DateTime> allDates = {...incomeMap.keys, ...expenseMap.keys};
    if (allDates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'কোন তথ্য নেই',
            style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    List<DateTime> sortedDates = allDates.toList()..sort();

    // Limit to last 7-10 entries for readability
    if (sortedDates.length > 7) {
      sortedDates = sortedDates.sublist(sortedDates.length - 7);
    }

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      incomeSpots.add(FlSpot(i.toDouble(), incomeMap[date] ?? 0));
      expenseSpots.add(FlSpot(i.toDouble(), expenseMap[date] ?? 0));
    }

    double maxY = 0;
    for (var spot in incomeSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    for (var spot in expenseSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = maxY == 0 ? 100 : maxY * 1.2;

    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < sortedDates.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat('dd/MM').format(sortedDates[index]),
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value >= 1000
                              ? '${(value / 1000).toStringAsFixed(1)}k'
                              : value.toInt().toString(),
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.success.withValues(alpha: 0.1),
                  ),
                ),
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  color: AppColors.error,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.error.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => AppColors.textPrimary.withValues(alpha: 0.9),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isIncome = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isIncome ? 'আয়' : 'ব্যয়'}: ${spot.y.toStringAsFixed(0)}',
                        GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 12),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('আয়', AppColors.success),
            const SizedBox(width: 24),
            _buildLegendItem('ব্যয়', AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections(List<Transaction> expenses) {
    Map<String, double> categorySums = {};
    for (var expense in expenses) {
      final category = expense.category.isEmpty ? 'অন্যান্য' : expense.category;
      categorySums[category] = (categorySums[category] ?? 0) + expense.amount;
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
      final category = expense.category.isEmpty ? 'অন্যান্য' : expense.category;
      categorySums[category] = (categorySums[category] ?? 0) + expense.amount;
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
