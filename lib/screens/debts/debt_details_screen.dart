import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import 'provider/debt_provider.dart';
import '../transactions/provider/transaction_provider.dart';
import '../accounts/provider/account_provider.dart';
import '../settings/provider/settings_provider.dart';
import '../../models/debt.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../services/ai_service.dart';

class DebtDetailsScreen extends StatefulWidget {
  final Debt debt;
  const DebtDetailsScreen({super.key, required this.debt});

  @override
  State<DebtDetailsScreen> createState() => _DebtDetailsScreenState();
}

class _DebtDetailsScreenState extends State<DebtDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
      }
    });
  }

  void _sendAiTagada(BuildContext context) {
    if (widget.debt.phoneNumber == null || widget.debt.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই ব্যক্তির কোন মোবাইল নম্বর সংরক্ষিত নেই!')),
      );
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'তগাদা মেসেজের ধরণ নির্বাচন করুন',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primary
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.green),
                title: Text('নরম / নম্র (Gentle)', style: GoogleFonts.hindSiliguri()),
                onTap: () => _generateAndLaunchReminder(context, 'gentle', settings.geminiApiKey),
              ),
              ListTile(
                leading: const Icon(Icons.sentiment_neutral_rounded, color: Colors.orange),
                title: Text('মাঝারি / সাধারণ (Moderate)', style: GoogleFonts.hindSiliguri()),
                onTap: () => _generateAndLaunchReminder(context, 'moderate', settings.geminiApiKey),
              ),
              ListTile(
                leading: const Icon(Icons.sentiment_very_dissatisfied_rounded, color: Colors.red),
                title: Text('কড়া / তাগিদপূর্ণ (Firm)', style: GoogleFonts.hindSiliguri()),
                onTap: () => _generateAndLaunchReminder(context, 'firm', settings.geminiApiKey),
              ),
            ],
          ),
        );
      },
    );
  }

  void _generateAndLaunchReminder(BuildContext context, String tone, String apiKey) async {
    Navigator.pop(context); // close bottom sheet

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final msg = await AiService.generateDueReminder(
        name: widget.debt.personName,
        amount: widget.debt.remainingAmount,
        dueDate: widget.debt.dueDate,
        tone: tone,
        apiKey: apiKey,
      );

      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        _showGeneratedReminderDialog(context, msg);
      }
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showGeneratedReminderDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('এআই তগাদা প্রস্তুত', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
          content: Text(message, style: GoogleFonts.hindSiliguri()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: GoogleFonts.hindSiliguri()),
            ),
            IconButton(
              icon: const Icon(Icons.message_rounded, color: Colors.green),
              tooltip: 'SMS পাঠান',
              onPressed: () async {
                final phone = widget.debt.phoneNumber;
                final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.blue),
              tooltip: 'WhatsApp পাঠান',
              onPressed: () async {
                final phone = widget.debt.phoneNumber;
                final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context) {
    double paymentAmount = 0.0;
    Account? selectedAccount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'কিস্তি পরিশোধ',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'পরিশোধের পরিমাণ ফিল্ড করুন। এটি আপনার মূল ব্যালেন্স থেকে বিয়োগ/যোগ হবে।',
                    style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '৳ ০.০০',
                      prefixIcon: Icon(Icons.money_rounded),
                    ),
                    onChanged: (val) => paymentAmount = double.tryParse(val) ?? 0.0,
                  ),
                  const SizedBox(height: 16),
                  Consumer<AccountProvider>(
                    builder: (context, provider, _) {
                      return DropdownButtonFormField<Account>(
                        decoration: const InputDecoration(
                          hintText: 'অ্যাকাউন্ট',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        items: provider.accounts.map((acc) {
                          return DropdownMenuItem(value: acc, child: Text(acc.name, style: GoogleFonts.hindSiliguri()));
                        }).toList(),
                        onChanged: (val) => selectedAccount = val,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (paymentAmount > 0 && selectedAccount != null) {
                          final debtProvider = Provider.of<DebtProvider>(context, listen: false);
                          await debtProvider.addPayment(
                            widget.debt,
                            paymentAmount,
                            selectedAccount!,
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'পেমেন্ট সম্পন্ন করুন',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'বিস্তারিত তথ্য',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('মুছে ফেলতে চান?', style: GoogleFonts.hindSiliguri()),
                  content: Text('এই তথ্যটি কি মুছে ফেলতে চান?', style: GoogleFonts.hindSiliguri()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('হ্যাঁ', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                final debtProvider = Provider.of<DebtProvider>(context, listen: false);
                await debtProvider.deleteDebt(widget.debt);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, _) {
          final history = txProvider.transactions.where((t) => t.debtId == widget.debt.id).toList();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsCard(),
                const SizedBox(height: 32),
                Text(
                  'পেমেন্ট হিস্ট্রি',
                  style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (history.isEmpty)
                  Center(
                    child: Text(
                      'কোন পেমেন্ট হিস্ট্রি নেই',
                      style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...history.map((tx) => _buildHistoryItem(tx)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.debt.status == 'Settled' 
        ? null 
          : Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showPaymentDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'পেমেন্ট যোগ করুন',
                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.debt.personName,
                    style: GoogleFonts.hindSiliguri(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.debt.type == 'Receivable' ? 'পাওনাদার' : 'দেনাদার',
                    style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (widget.debt.type == 'Receivable' ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.debt.type == 'Receivable' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: widget.debt.type == 'Receivable' ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('মোট পরিমাণ', '৳${widget.debt.amount.toStringAsFixed(0)}'),
              _buildStatItem('অবশিষ্ট', '৳${widget.debt.remainingAmount.toStringAsFixed(0)}', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.debt.phoneNumber != null && widget.debt.phoneNumber!.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendAiTagada(context),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text('এআই তগাদা', style: GoogleFonts.hindSiliguri()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                      foregroundColor: Colors.purple,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:${widget.debt.phoneNumber}');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text('কল করুন', style: GoogleFonts.hindSiliguri()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payment_rounded, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'কিস্তি জমা',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd MMMM, yyyy').format(tx.date),
                  style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '৳${tx.amount.toStringAsFixed(0)}',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
