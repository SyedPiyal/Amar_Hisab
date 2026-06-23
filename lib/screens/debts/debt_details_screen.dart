import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../providers/debt_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/settings_provider.dart';
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
    Future.microtask(() => Provider.of<TransactionProvider>(context, listen: false).loadTransactions());
  }

  void _sendAiTagada(BuildContext context) {
    if (widget.debt.phoneNumber == null || widget.debt.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই ব্যক্তির কোন মোবাইল নম্বর সংরক্ষিত নেই!')),
      );
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);

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
                style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                          await Provider.of<DebtProvider>(context, listen: false).addPayment(
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
              if (confirm == true) {
                await Provider.of<DebtProvider>(context, listen: false).deleteDebt(widget.debt);
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
                  widget.debt.type == 'Receivable' ? Icons.call_received_rounded : Icons.call_made_rounded,
                  color: widget.debt.type == 'Receivable' ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildInfoRow('মোট পরিমাণ:', '৳ ${NumberFormat('#,###').format(widget.debt.amount)}'),
          const Divider(height: 32),
          _buildInfoRow('অবশিষ্ট:', '৳ ${NumberFormat('#,###').format(widget.debt.remainingAmount)}', isBold: true),
          const Divider(height: 32),
          _buildInfoRow('শুরু হয়েছে:', DateFormat('dd MMM yyyy').format(widget.debt.date)),
          if (widget.debt.dueDate != null) ...[
            const Divider(height: 32),
            _buildInfoRow('শেষ তারিখ:', DateFormat('dd MMM yyyy').format(widget.debt.dueDate!)),
          ],
          if (widget.debt.note != null && widget.debt.note!.isNotEmpty) ...[
            const Divider(height: 32),
            _buildInfoRow('নোট:', widget.debt.note!),
          ],
          if (widget.debt.phoneNumber != null && widget.debt.phoneNumber!.isNotEmpty) ...[
            const Divider(height: 32),
            _buildInfoRow('মোবাইল নম্বর:', widget.debt.phoneNumber!),
          ],
          if (widget.debt.type == 'Receivable' && widget.debt.status != 'Settled') ...[
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _sendAiTagada(context),
                icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                label: Text('এআই তগাদা (SMS/WhatsApp Remind)', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Transaction tx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          tx.type == 'Income' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: tx.type == 'Income' ? AppColors.success : AppColors.error,
        ),
        title: Text(tx.title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500)),
        subtitle: Text(DateFormat('dd MMM yyyy').format(tx.date), style: GoogleFonts.inter(fontSize: 12)),
        trailing: Text(
          '৳ ${NumberFormat('#,###').format(tx.amount)}',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
