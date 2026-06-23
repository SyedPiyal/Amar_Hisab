import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';

class BankReconciliationScreen extends StatefulWidget {
  const BankReconciliationScreen({super.key});

  @override
  State<BankReconciliationScreen> createState() => _BankReconciliationScreenState();
}

class _BankReconciliationScreenState extends State<BankReconciliationScreen> {
  Account? _selectedAccount;
  List<Map<String, dynamic>> _statementItems = [];
  bool _isFileUploaded = false;

  // Mock statements for BDT Cash/Bank
  final List<String> _mockCsvData = [
    'Date,Description,Amount,Type',
    '2026-06-14,বিকাশ সেন্ড মানি (Karim),500.0,Expense',
    '2026-06-13,বেতন প্রাপ্তি (Salary),25000.0,Income',
    '2026-06-12,বাজার খরচ (Rice & Oil),1200.0,Expense',
    '2026-06-11,ইন্টারনেট বিল পরিশোধ,1000.0,Expense',
    '2026-06-10,নগদ উত্তোলন ATM,5000.0,Transfer',
  ];

  void _loadMockStatement() {
    setState(() {
      _statementItems = _mockCsvData.skip(1).map((line) {
        final cols = line.split(',');
        return {
          'date': DateTime.parse(cols[0]),
          'description': cols[1],
          'amount': double.parse(cols[2]),
          'type': cols[3],
          'status': 'Pending', // Pending, Matched, Partial, Unmatched
          'matchedTx': null,
        };
      }).toList();
      _isFileUploaded = true;
      _performMatching();
    });
  }

  void _performMatching() {
    if (_selectedAccount == null) return;
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    for (var item in _statementItems) {
      final double amount = item['amount'];
      final DateTime date = item['date'];
      final String type = item['type'];

      // Find best match in provider
      Transaction? bestMatch;
      String status = 'Unmatched';

      for (var tx in txProvider.transactions) {
        // Must belong to this account
        if (tx.accountId != _selectedAccount!.id) continue;

        // Check if amount matches
        if ((tx.amount - amount).abs() < 0.01) {
          // Check date matches exactly
          if (tx.date.year == date.year && tx.date.month == date.month && tx.date.day == date.day) {
            bestMatch = tx;
            status = 'Matched';
            break;
          } else if (tx.date.difference(date).inDays.abs() <= 3) {
            // Partial match if within 3 days
            bestMatch = tx;
            status = 'Partial';
          }
        }
      }

      item['status'] = status;
      item['matchedTx'] = bestMatch;
    }
  }

  void _reconcileItem(int index) {
    setState(() {
      _statementItems[index]['status'] = 'Matched';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('লেনদেনটি সফলভাবে রিকনসাইল করা হয়েছে')),
    );
  }

  void _addMissingTransaction(int index) async {
    if (_selectedAccount == null) return;
    final item = _statementItems[index];

    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: item['description'],
      amount: item['amount'],
      date: item['date'],
      accountId: _selectedAccount!.id,
      type: item['type'] == 'Transfer' ? 'Expense' : item['type'],
      category: item['type'] == 'Income' ? 'Salary' : 'Other',
    );

    await txProvider.addTransaction(newTx, _selectedAccount!);
    _performMatching();
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('নতুন লেনদেন যোগ ও রিকনসাইল করা হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ব্যাংক রিকনসিলিয়েশন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Selector Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'রিকনসাইল করার জন্য অ্যাকাউন্ট নির্বাচন করুন',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Account>(
                      value: _selectedAccount,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      hint: Text('অ্যাকাউন্ট সিলিন করুন', style: GoogleFonts.hindSiliguri()),
                      items: accountProvider.accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc.name, style: GoogleFonts.hindSiliguri()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAccount = val;
                          if (_isFileUploaded) _performMatching();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (!_isFileUploaded)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload_outlined, size: 64, color: AppColors.primary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'ব্যাংক স্টেটমেন্ট ফাইল আপলোড করুন',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'আপনার ব্যাংক থেকে ডাউনলোড করা CSV/Excel ফাইল আপলোড করুন',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _selectedAccount == null ? null : _loadMockStatement,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text('স্টেটমেন্ট সিমুলেট করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'স্টেটমেন্টের হিসাবসমূহ',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _isFileUploaded = false),
                          icon: const Icon(Icons.refresh),
                          label: Text('নতুন ফাইল', style: GoogleFonts.hindSiliguri()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _statementItems.length,
                        itemBuilder: (context, index) {
                          final item = _statementItems[index];
                          return _buildReconciliationItemTile(item, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconciliationItemTile(Map<String, dynamic> item, int index) {
    final DateTime date = item['date'];
    final double amount = item['amount'];
    final String desc = item['description'];
    final String status = item['status'];
    final Transaction? matchedTx = item['matchedTx'];
    final bool isIncome = item['type'] == 'Income';

    Color statusColor = Colors.red;
    String statusText = 'অমিল (Unmatched)';
    IconData statusIcon = Icons.error_outline_rounded;

    if (status == 'Matched') {
      statusColor = Colors.green;
      statusText = 'মিলেছে (Matched)';
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (status == 'Partial') {
      statusColor = Colors.orange;
      statusText = 'আংশিক মিল (Partial)';
      statusIcon = Icons.warning_amber_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        desc,
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'তারিখ: ${DateFormat('dd-MM-yyyy').format(date)}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? "+" : "-"} ৳${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : AppColors.error,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.hindSiliguri(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                if (status == 'Unmatched')
                  ElevatedButton(
                    onPressed: () => _addMissingTransaction(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('হিসাব লিখুন', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else if (status == 'Partial')
                  Row(
                    children: [
                      Text(
                        'মিলেছে: ${matchedTx?.title}',
                        style: GoogleFonts.hindSiliguri(fontSize: 11, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _reconcileItem(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('নিশ্চিত করুন', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                else
                  Text(
                    'আইডি: ${matchedTx?.id ?? "রিকনসাইলড"}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
