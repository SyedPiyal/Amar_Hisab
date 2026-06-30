import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';

class TransactionItem extends StatefulWidget {
  const TransactionItem({super.key, this.tx});

  final dynamic tx;

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
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
                color: isIncome
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
