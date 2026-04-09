import 'package:amar_hisab/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../theme/app_colors.dart';
import '../accounts/accounts_overview_screen.dart';
import '../transactions/transactions_list_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../settings/more_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import '../../providers/settings_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currencySymbol = settings.currency == 'BDT'
        ? '৳ '
        : (settings.currency == 'USD' ? '\$' : '${settings.currency} ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'আমার ড্যাশবোর্ড',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Net Balance Card
            Consumer2<AccountProvider, TransactionProvider>(
              builder: (context, accountProvider, transactionProvider, _) {
                final balanceFormat = NumberFormat.currency(
                  locale: settings.language == 'bn' ? 'bn_BD' : 'en_US',
                  symbol: currencySymbol,
                  decimalDigits: 2,
                );

                double totalIncome = 0.0;
                double totalExpense = 0.0;
                for (var tx in transactionProvider.transactions) {
                  if (tx.type == 'Income') {
                    totalIncome += tx.amount;
                  } else if (tx.type == 'Expense') {
                    totalExpense += tx.amount;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'মোট ব্যালেন্স (Net Balance)',
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          balanceFormat.format(accountProvider.totalBalance),
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceInfo(
                              'আয় (Income)',
                              balanceFormat.format(totalIncome),
                              Icons.arrow_downward_rounded,
                            ),
                            _buildBalanceInfo(
                              'ব্যয় (Expense)',
                              balanceFormat.format(totalExpense),
                              Icons.arrow_upward_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceInfo(
                              'নগদ (Cash)',
                              balanceFormat.format(accountProvider.cashBalance),
                              Icons.money_rounded,
                            ),
                            _buildBalanceInfo(
                              'ব্যাংক (Bank)',
                              balanceFormat.format(accountProvider.bankBalance),
                              Icons.food_bank_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Ratio Bar
                        if (totalIncome > 0 || totalExpense > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value:
                                      totalIncome /
                                      (totalIncome + totalExpense),
                                  backgroundColor: AppColors.error.withValues(
                                    alpha: 0.5,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.success,
                                      ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'আয়ের অনুপাত: ${((totalIncome / (totalIncome + totalExpense)) * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.hindSiliguri(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    'ব্যয়ের অনুপাত: ${((totalExpense / (totalIncome + totalExpense)) * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.hindSiliguri(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Recent Transactions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'সাম্প্রতিক লেনদেন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TransactionsListScreen(),
                        ),
                      );
                    },
                    child: const Text('সবগুলো দেখুন'),
                  ),
                ],
              ),
            ),

            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, _) {
                final recentTransactions = transactionProvider.transactions
                    .take(3)
                    .toList();

                if (recentTransactions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'কোন লেনদেন নেই',
                        style: GoogleFonts.hindSiliguri(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = recentTransactions[index];
                    return _buildTransactionItem(tx);
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Financial Health Chart (REAL DATA with Income & Expense)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'আর্থিক অবস্থা',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'শেষ ৭ দিনের লেনদেন চিত্র',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Legend Labels
                      Row(
                        children: [
                          _buildChartLegend('আয় (Income)', Colors.green),
                          const SizedBox(width: 16),
                          _buildChartLegend('ব্যয় (Expense)', AppColors.error),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      Consumer<TransactionProvider>(
                        builder: (context, provider, _) {
                          final expenseSpots = _getLineChartSpots(provider.transactions, 'Expense');
                          final incomeSpots = _getLineChartSpots(provider.transactions, 'Income');
                          
                          if (expenseSpots.isEmpty && incomeSpots.isEmpty) {
                            return const SizedBox(
                              height: 200,
                              child: Center(child: Text('পর্যপ্ত তথ্য নেই')),
                            );
                          }

                          return SizedBox(
                            height: 220,
                            child: LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipColor: (spot) => AppColors.surface,
                                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        return LineTooltipItem(
                                          '৳${spot.y.toStringAsFixed(0)}',
                                          GoogleFonts.inter(
                                            color: spot.bar.color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: AppColors.border.withValues(alpha: 0.5),
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 || index >= 7) return const SizedBox.shrink();
                                        final date = DateTime.now().subtract(Duration(days: 6 - index));
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            DateFormat('dd/MM').format(date),
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0) return const SizedBox.shrink();
                                        String text = '';
                                        if (value >= 1000) {
                                          text = '${(value / 1000).toStringAsFixed(1)}k';
                                        } else {
                                          text = value.toStringAsFixed(0);
                                        }
                                        return Text(
                                          text,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                          textAlign: TextAlign.left,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  // Income Line
                                  LineChartBarData(
                                    spots: incomeSpots,
                                    isCurved: true,
                                    color: Colors.green,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.green.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  // Expense Line
                                  LineChartBarData(
                                    spots: expenseSpots,
                                    isCurved: true,
                                    color: AppColors.error,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppColors.error.withValues(alpha: 0.05),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountsOverviewScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TransactionsListScreen(),
              ),
            );
          } else if (index == 4) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const MoreScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'হোম'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'অ্যাকাউন্ট',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'যোগ করুন',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'লেনদেন',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'আরও',
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getLineChartSpots(List<dynamic> transactions, String type) {
    // Filter last 7 days and group by date
    final now = DateTime.now();
    final Map<int, double> dailySums = {};

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      dailySums[i] = 0.0;
      for (var tx in transactions) {
        if (tx.date.day == date.day &&
            tx.date.month == date.month &&
            tx.date.year == date.year &&
            tx.type == type) {
          dailySums[i] = dailySums[i]! + tx.amount;
        }
      }
    }

    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), dailySums[6 - index]!);
    });
  }

  Widget _buildBalanceInfo(String label, String amount, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    final bool isIncome = tx.type == 'Income';
    final balanceFormat = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '৳',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM, yyyy - hh:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isIncome
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.shopping_bag_outlined,
                color: isIncome ? Colors.green : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    tx.type,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ${balanceFormat.format(tx.amount)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateFormat.format(tx.date),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
