import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/settings_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _type = 'ব্যয়'; // 'আয়', 'ব্যয়', 'ট্রান্সফার'
  double _amount = 0.0;
  final TextEditingController _titleController = TextEditingController();
  
  Account? _selectedAccount; // For Simple Mode
  
  // For Advanced Mode
  Account? _fromAccount;
  Account? _toAccount;
  
  bool _isSplit = false;
  final List<Map<String, dynamic>> _splitItems = []; // {category: String, amount: double, controller: TextEditingController}

  double get _totalSplitAmount => _splitItems.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  double get _remainingAmount => _amount - _totalSplitAmount;

  void _addSplitItem() {
    setState(() {
      _splitItems.add({
        'category': '',
        'amount': 0.0,
        'controller': TextEditingController(text: '0.0'),
      });
    });
  }

  void _removeSplitItem(int index) {
    setState(() {
      _splitItems[index]['controller'].dispose();
      _splitItems.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var item in _splitItems) {
      item['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... [existing build logic]
    final settings = Provider.of<SettingsProvider>(context);
    final isAdvanced = settings.isAdvancedMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'লেনদেন যোগ করুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Field
            Center(
              child: _buildAmountField(settings.currency),
            ),
            const SizedBox(height: 48),

            // Type Selector (For Simple Mode predominantly, but also useful for Quick Selection in Advanced)
            _buildTypeSelector(),
            const SizedBox(height: 32),

            // Title/Category
            _buildFieldHeader('বিবরণ / ক্যাটাগরি'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'উদা: বাজার খরচ, স্যালারি',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 24),

            // Account Selection based on Mode
            if (!isAdvanced) ...[
              _buildFieldHeader('অ্যাকাউন্ট'),
              _buildAccountDropdown(
                value: _selectedAccount,
                onChanged: (val) => setState(() => _selectedAccount = val),
              ),
            ] else ...[
              _buildFieldHeader('প্রদানকারী অ্যাকাউন্ট (From / Credit)'),
              _buildAccountDropdown(
                value: _fromAccount,
                onChanged: (val) => setState(() => _fromAccount = val),
                hint: 'টাকা কোথা থেকে আসছে?',
              ),
              const SizedBox(height: 24),
              _buildFieldHeader('গ্রহীতা অ্যাকাউন্ট (To / Debit)'),
              _buildAccountDropdown(
                value: _toAccount,
                onChanged: (val) => setState(() => _toAccount = val),
                hint: 'টাকা কোথায় যাচ্ছে?',
              ),
            ],
            const SizedBox(height: 24),

            // Split Transaction Toggle
            if (isAdvanced) ...[
              _buildSplitToggle(),
              if (_isSplit) _buildSplitForm(),
              const SizedBox(height: 24),
            ],

            // Date Selection (Static for now as per original)
            _buildFieldHeader('তারিখ'),
            const TextField(
              decoration: InputDecoration(
                hintText: 'আজ, ০৭ এপ্রিল ২০২৬',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 48),

            _buildSubmitButton(isAdvanced),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(String currency) {
    return Column(
      children: [
        Text(
          'টাকার পরিমাণ',
          style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        IntrinsicWidth(
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '$currency ০.০০',
              border: InputBorder.none,
            ),
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            onChanged: (val) {
              setState(() {
                _amount = double.tryParse(val) ?? 0.0;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(child: _buildTypeButton('আয়', _type == 'আয়')),
        const SizedBox(width: 16),
        Expanded(child: _buildTypeButton('ব্যয়', _type == 'ব্যয়')),
        const SizedBox(width: 16),
        Expanded(child: _buildTypeButton('ট্রান্সফার', _type == 'ট্রান্সফার')),
      ],
    );
  }

  Widget _buildAccountDropdown({
    required Account? value,
    required Function(Account?) onChanged,
    String hint = 'সিলেক্ট করুন',
  }) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        return DropdownButtonFormField<Account>(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          value: value,
          items: provider.accounts.map((acc) {
            return DropdownMenuItem(value: acc, child: Text(acc.name));
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  Widget _buildSplitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'স্প্লিট ট্রানজ্যাকশন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
        ),
        Switch(
          value: _isSplit,
          onChanged: (val) => setState(() => _isSplit = val),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSplitForm() {
    return Card(
      color: Colors.white,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ক্যাটাগরি অনুযায়ী ভাগ করুন',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addSplitItem,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: Text(
                    'নতুন আইটেম',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (_splitItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'অন্তত একটি ক্যাটাগরি যোগ করুন',
                    style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
                  ),
                ),
              ),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _splitItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _splitItems[index];
                return Row(
                  children: [
                    // Category Input
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'ক্যাটাগরি (উদা: ফুড)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: GoogleFonts.hindSiliguri(fontSize: 14),
                        onChanged: (val) => setState(() => item['category'] = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Amount Input
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: item['controller'],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'পরিমাণ',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                        onChanged: (val) {
                          setState(() {
                            item['amount'] = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                      onPressed: () => _removeSplitItem(index),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _remainingAmount == 0 
                  ? AppColors.success.withValues(alpha: 0.1) 
                  : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'অবশিষ্ট টাকা (Remaining):',
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      color: _remainingAmount == 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    '৳ ${_remainingAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: _remainingAmount == 0 ? AppColors.success : AppColors.error,
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

  Widget _buildSubmitButton(bool isAdvanced) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _submitTransaction(isAdvanced),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          'নিশ্চিত করুন',
          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _submitTransaction(bool isAdvanced) async {
    final title = _titleController.text;
    
    bool isValid = false;
    if (isAdvanced) {
      isValid = _fromAccount != null && _toAccount != null && _amount > 0 && title.isNotEmpty;
      if (_isSplit && isValid) {
        isValid = _remainingAmount == 0 && _splitItems.isNotEmpty;
      }
    } else {
      isValid = _selectedAccount != null && _amount > 0 && title.isNotEmpty;
    }

    if (isValid) {
      Map<String, double> splitMap = {};
      if (_isSplit) {
        for (var item in _splitItems) {
          splitMap[item['category']] = item['amount'];
        }
      }

      final tx = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: _amount,
        date: DateTime.now(),
        accountId: isAdvanced ? _toAccount!.id : _selectedAccount!.id,
        creditAccountId: isAdvanced ? _fromAccount!.id : null,
        debitAccountId: isAdvanced ? _toAccount!.id : null,
        type: _type == 'আয়' ? 'Income' : (_type == 'ব্যয়' ? 'Expense' : 'Transfer'),
        category: title,
        isSplit: _isSplit,
        splitDetails: _isSplit ? splitMap : null,
      );

      await Provider.of<TransactionProvider>(context, listen: false).addTransaction(
        tx,
        isAdvanced ? _toAccount! : _selectedAccount!,
        creditAccount: isAdvanced ? _fromAccount : null,
      );
      
      if (mounted) Navigator.of(context).pop();
    } else {
      String error = 'অনুগ্রহ করে সব তথ্য সঠিক ভাবে দিন';
      if (_isSplit && _remainingAmount != 0) {
        error = 'স্প্লিট পরিমাণের যোগফল মোট পরিমাণের সমান হতে হবে (অবশিষ্ট: ৳ ${_remainingAmount.toStringAsFixed(2)})';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Widget _buildFieldHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _type = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.hindSiliguri(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
