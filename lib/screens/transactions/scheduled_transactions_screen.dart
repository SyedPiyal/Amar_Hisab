import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/scheduled_transaction.dart';
import '../../models/account.dart';
import '../../providers/scheduled_transaction_provider.dart';
import '../../providers/account_provider.dart';

class ScheduledTransactionsScreen extends StatefulWidget {
  const ScheduledTransactionsScreen({super.key});

  @override
  State<ScheduledTransactionsScreen> createState() => _ScheduledTransactionsScreenState();
}

class _ScheduledTransactionsScreenState extends State<ScheduledTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ScheduledTransactionProvider>(context, listen: false).loadSchedules());
  }

  void _showAddScheduleSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    Account? selectedAccount;
    String frequency = 'Monthly'; // Daily, Weekly, Monthly
    String type = 'Expense'; // Income, Expense
    String category = 'Utilities';
    DateTime nextDueDate = DateTime.now();

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'নতুন নির্ধারিত লেনদেন',
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
                    
                    // Title input
                    Text(
                      'শিরোনাম (Title)',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'উদা: ইন্টারনেট বিল, ডিপিএস কিস্তি',
                      ),
                      style: GoogleFonts.hindSiliguri(),
                    ),
                    const SizedBox(height: 16),

                    // Amount input
                    Text(
                      'পরিমাণ (Amount)',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '৳ ০.০০',
                      ),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Type selectors
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text('ব্যয় (Expense)', style: GoogleFonts.hindSiliguri()),
                            selected: type == 'Expense',
                            onSelected: (val) {
                              if (val) setModalState(() => type = 'Expense');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ChoiceChip(
                            label: Text('আয় (Income)', style: GoogleFonts.hindSiliguri()),
                            selected: type == 'Income',
                            onSelected: (val) {
                              if (val) setModalState(() => type = 'Income');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Account Selection
                    Text(
                      'অ্যাকাউন্ট',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Consumer<AccountProvider>(
                      builder: (context, provider, _) {
                        return DropdownButtonFormField<Account>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          hint: Text('অ্যাকাউন্ট নির্বাচন করুন', style: GoogleFonts.hindSiliguri()),
                          value: selectedAccount,
                          items: provider.accounts.map((acc) {
                            return DropdownMenuItem(
                              value: acc,
                              child: Text(acc.name, style: GoogleFonts.hindSiliguri()),
                            );
                          }).toList(),
                          onChanged: (val) => setModalState(() => selectedAccount = val),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Frequency Selection
                    Text(
                      'পুনরাবৃত্তি (Frequency)',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: frequency,
                      items: const [
                        DropdownMenuItem(value: 'Daily', child: Text('দৈনিক (Daily)')),
                        DropdownMenuItem(value: 'Weekly', child: Text('সাপ্তাহিক (Weekly)')),
                        DropdownMenuItem(value: 'Monthly', child: Text('মাসিক (Monthly)')),
                      ],
                      onChanged: (val) => setModalState(() => frequency = val ?? 'Monthly'),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    Text(
                      'পরবর্তী বিলিং তারিখ',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      title: Text(
                        DateFormat('dd-MM-yyyy').format(nextDueDate),
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: nextDueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setModalState(() => nextDueDate = picked);
                        }
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text) ?? 0.0;

                          if (title.isNotEmpty && amount > 0 && selectedAccount != null) {
                            final newSchedule = ScheduledTransaction(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              amount: amount,
                              accountId: selectedAccount!.id,
                              type: type,
                              category: category,
                              frequency: frequency,
                              nextDueDate: nextDueDate,
                            );

                            await Provider.of<ScheduledTransactionProvider>(context, listen: false)
                                .addSchedule(newSchedule);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('নির্ধারিত লেনদেন সফলভাবে সংরক্ষণ করা হয়েছে')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'নির্ধারিত শিডিউল সংরক্ষণ করুন',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'নির্ধারিত লেনদেন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ScheduledTransactionProvider>(
        builder: (context, provider, _) {
          if (provider.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 64, color: AppColors.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'কোন নির্ধারিত লেনদেন নেই',
                    style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'পরবর্তী কিস্তি বা বিল অটো এন্ট্রি করতে শিডিউল যোগ করুন',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.schedules.length,
            itemBuilder: (context, index) {
              final schedule = provider.schedules[index];
              return _buildScheduledItem(context, schedule, provider, accountProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddScheduleSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
        label: Text(
          'নতুন শিডিউল',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildScheduledItem(
    BuildContext context,
    ScheduledTransaction schedule,
    ScheduledTransactionProvider provider,
    AccountProvider accountProvider,
  ) {
    final format = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '৳',
      decimalDigits: 0,
    );

    final account = accountProvider.accounts.firstWhere(
      (a) => a.id == schedule.accountId,
      orElse: () => Account(id: '', name: 'অজানা', type: '', iconName: ''),
    );

    String freqLabel = 'মাসিক';
    if (schedule.frequency == 'Daily') {
      freqLabel = 'দৈনিক';
    } else if (schedule.frequency == 'Weekly') {
      freqLabel = 'সাপ্তাহিক';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (schedule.type == 'Income' ? Colors.green : AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            schedule.type == 'Income' ? Icons.arrow_downward_rounded : Icons.repeat_rounded,
            color: schedule.type == 'Income' ? Colors.green : AppColors.primary,
          ),
        ),
        title: Text(
          schedule.title,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'পুনরাবৃত্তি: $freqLabel • পরবর্তী তারিখ: ${DateFormat('dd-MM-yyyy').format(schedule.nextDueDate)}',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${format.format(schedule.amount)} • ${account.name}',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: schedule.type == 'Income' ? Colors.green : AppColors.primary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: schedule.isActive,
              onChanged: (val) => provider.toggleSchedule(schedule, val),
              activeColor: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('মুছে ফেলুন', style: GoogleFonts.hindSiliguri()),
                    content: Text('এই নির্ধারিত শিডিউলটি কি মুছে ফেলতে চান?', style: GoogleFonts.hindSiliguri()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('হ্যাঁ', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                );
                if (confirm == true) {
                  provider.deleteSchedule(schedule);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
