import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../transactions/provider/transaction_provider.dart';

class TopExpenses extends StatefulWidget {
  const TopExpenses({super.key});

  @override
  State<TopExpenses> createState() => _TopExpensesState();
}

class _TopExpensesState extends State<TopExpenses> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final topTxs = provider.todayTopTransactions;

    if (topTxs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'আজকের সর্বোচ্চ খরচ (টপ ৩)',
            style: GoogleFonts.hindSiliguri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...topTxs.map(
              (tx) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tx.title,
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '৳${NumberFormat('#,###').format(tx.amount)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
