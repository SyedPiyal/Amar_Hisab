import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../transactions/provider/transaction_provider.dart';

class FinancialHealthChart extends StatelessWidget {
  const FinancialHealthChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  final expenseSpots = _getLineChartSpots(
                    provider.transactions,
                    'Expense',
                  );
                  final incomeSpots = _getLineChartSpots(
                    provider.transactions,
                    'Income',
                  );

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
                            color: AppColors.border.withValues(
                              alpha: 0.5,
                            ),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= 7) {
                                  return const SizedBox.shrink();
                                }
                                final date = DateTime.now().subtract(
                                  Duration(days: 6 - index),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                  ),
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
                              color: Colors.green.withValues(
                                alpha: 0.05,
                              ),
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
                              color: AppColors.error.withValues(
                                alpha: 0.05,
                              ),
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
}
