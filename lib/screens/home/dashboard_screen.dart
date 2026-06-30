import 'package:amar_hisab/screens/home/widgets/ai_advice_card.dart';
import 'package:amar_hisab/screens/home/widgets/financial_health_chart.dart';
import 'package:amar_hisab/screens/home/widgets/net_balance_card.dart';
import 'package:amar_hisab/screens/home/widgets/quick_action.dart';
import 'package:amar_hisab/screens/home/widgets/savings_tracker.dart';
import 'package:amar_hisab/screens/home/widgets/top_expenses.dart';
import 'package:amar_hisab/screens/home/widgets/transaction_item.dart';
import 'package:amar_hisab/screens/home/widgets/home_bottom_nav.dart';
import 'package:amar_hisab/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../transactions/transactions_list_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import '../settings/provider/settings_provider.dart';
import '../accounts/provider/account_provider.dart';
import '../transactions/provider/transaction_provider.dart';
import '../transactions/provider/scheduled_transaction_provider.dart';
import '../../services/ai_service.dart';
import '../ai_chat/chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _aiAdvice = '';
  bool _isLoadingAdvice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final txProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      final accountProvider = Provider.of<AccountProvider>(
        context,
        listen: false,
      );
      final scheduledProvider = Provider.of<ScheduledTransactionProvider>(
        context,
        listen: false,
      );

      // Load and process scheduled transactions
      scheduledProvider.loadSchedules().then((_) {
        scheduledProvider.processDueTransactions(txProvider, accountProvider);
      });

      _loadAiAdvice();
    });
  }

  void _loadAiAdvice() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAdvice = true;
    });

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (var tx in txProvider.transactions) {
      if (tx.type == 'Income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'Expense') {
        totalExpense += tx.amount;
      }
    }
    double netSavings = totalIncome - totalExpense;

    try {
      final advice = await AiService.generateFinancialAdvice(
        totalIncome,
        totalExpense,
        netSavings,
        settings.geminiApiKey,
      );
      if (mounted) {
        setState(() {
          _aiAdvice = advice;
          _isLoadingAdvice = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAdvice = false;
        });
      }
    }
  }

  void _openChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    ).then((_) {
      _loadAiAdvice();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            const NetBalanceCard(),
            const SavingsTracker(),
            AiAdviceCard(
              advice: _aiAdvice,
              isLoading: _isLoadingAdvice,
              onRefresh: _loadAiAdvice,
            ),

            QuickAction(),

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
                    return TransactionItem(tx: tx);
                  },
                );
              },
            ),

            const SizedBox(height: 16),
            TopExpenses(),
            const SizedBox(height: 20),

            // Financial Health Chart (REAL DATA with Income & Expense)
            const FinancialHealthChart(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openChatScreen,
        backgroundColor: Colors.purple.shade600,
        tooltip: 'AI Chat Assistant',
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      ),
      bottomNavigationBar: const HomeBottomNav(currentIndex: 0),
    );
  }
}
