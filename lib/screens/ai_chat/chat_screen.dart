import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../theme/app_colors.dart';
import '../../models/chat_message.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/debt_provider.dart';
import '../../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<Content> _history = [];
  
  bool _isLoading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _addSystemMessage("হ্যালো! আমি আপনার এআই ফাইন্যান্সিয়াল অ্যাসিস্ট্যান্ট। আমাকে হিসাব যোগ করতে বা ব্যালেন্স সম্পর্কে জিজ্ঞাসা করতে পারেন।");
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _addUserMessage(text);
    
    setState(() {
      _isLoading = true;
    });

    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
    
    final responseText = await AiService.chatWithAssistant(
      message: text,
      history: _history,
      apiKey: settings.geminiApiKey,
      onCallTool: _handleToolCall,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  Future<Map<String, Object?>> _handleToolCall(String name, Map<String, Object?> args) async {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final debtProvider = Provider.of<DebtProvider>(context, listen: false);

    try {
      if (name == 'addTransaction') {
        final amount = (args['amount'] as num).toDouble();
        final type = args['type'] as String; // Expense or Income
        final category = args['category'] as String;
        final accountName = args['account'] as String;
        final title = args['title'] as String;

        Account? account = accountProvider.accounts.where(
          (a) => a.name.toLowerCase().contains(accountName.toLowerCase()),
        ).firstOrNull ?? accountProvider.accounts.first;

        final newTx = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          amount: amount,
          type: type == 'Income' ? 'Income' : 'Expense',
          category: category,
          accountId: account.id,
          date: DateTime.now(),
        );

        await txProvider.addTransaction(newTx, account);
        
        return {
          'status': 'success',
          'message': 'Successfully added $amount as $type for $title in $accountName.'
        };
      } 
      else if (name == 'addDebt') {
        final personName = args['personName'] as String;
        final amount = (args['amount'] as num).toDouble();
        final type = args['type'] as String; // Give or Take

        await debtProvider.addDebt(
          personName: personName,
          amount: amount,
          type: type == 'Take' ? 'Payable' : 'Receivable',
        );

        return {
          'status': 'success',
          'message': 'Successfully added $amount debt for $personName ($type).'
        };
      }
      else if (name == 'getFinancialSummary') {
        double income = 0;
        double expense = 0;
        final now = DateTime.now();
        for (var tx in txProvider.transactions) {
          if (tx.date.month == now.month && tx.date.year == now.year) {
            if (tx.type == 'Income') income += tx.amount;
            if (tx.type == 'Expense') expense += tx.amount;
          }
        }
        return {
          'status': 'success',
          'totalIncomeThisMonth': income,
          'totalExpenseThisMonth': expense,
          'totalBalance': accountProvider.totalBalance,
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
    return {'status': 'error', 'message': 'Unknown function'};
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _textController.text = val.recognizedWords;
            });
          },
          listenOptions: stt.SpeechListenOptions(
            localeId: 'bn_BD',
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'এআই অ্যাসিস্ট্যান্ট',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('আপনি ভয়েস বা টেক্সটের মাধ্যমে হিসাব যোগ করতে পারেন।')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.hindSiliguri(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : AppColors.primary,
              ),
              onPressed: _listen,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'আপনার বার্তা লিখুন...',
                  hintStyle: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: _handleSubmitted,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
