import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import 'provider/transaction_provider.dart';
import '../accounts/provider/account_provider.dart';
import '../settings/provider/settings_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/ai_voice_dialog.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialAmount;
  const AddTransactionScreen({super.key, this.initialCategory, this.initialAmount});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _type = 'ব্যয়'; // 'আয়', 'ব্যয়', 'ট্রান্সফার'
  double _amount = 0.0;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _taxController = TextEditingController(text: '0');
  
  Account? _selectedAccount; // For Simple Mode
  Account? _fromAccount; // For Advanced Mode
  Account? _toAccount; // For Advanced Mode
  
  bool _isSplit = false;
  final List<Map<String, dynamic>> _splitItems = [];

  List<String> _attachmentPaths = [];
  final ImagePicker _picker = ImagePicker();

  double get _taxPercentage => double.tryParse(_taxController.text) ?? 0.0;
  double get _taxAmount => _amount * (_taxPercentage / 100);

  double get _totalSplitAmount => _splitItems.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  double get _remainingAmount => _amount - _totalSplitAmount;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _titleController.text = widget.initialCategory!;
    }
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!;
      _amount = double.tryParse(widget.initialAmount!) ?? 0.0;
    }
  }

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

  Future<void> _pickAttachment() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _attachmentPaths.add(image.path);
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অ্যাটাচমেন্ট যোগ করতে ব্যর্থ হয়েছে')),
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachmentPaths.removeAt(index);
    });
  }

  Future<void> _scanReceiptOCR() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      final bytes = await image.readAsBytes();
      final result = await AiService.parseReceiptImage(bytes, settings.geminiApiKey);

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        setState(() {
          _amount = (result['amount'] as num).toDouble();
          _amountController.text = _amount.toString();
          _titleController.text = result['vendor'] ?? 'স্বপ্ন সুপার শপ';
          _attachmentPaths.add(image.path);

          // Find match for category/type
          final category = result['category'] ?? 'Groceries';
          _type = 'ব্যয়';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('রসিদ সফলভাবে স্ক্যান ও ফর্ম ফিল করা হয়েছে!')),
        );
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _showVoiceCommandDialog() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AiVoiceDialog(apiKey: settings.geminiApiKey),
    );

    if (result != null && mounted) {
      setState(() {
        _amount = (result['amount'] as num).toDouble();
        _amountController.text = _amount.toString();
        _titleController.text = result['title'] ?? 'ভয়েস এন্ট্রি';
        _type = result['type'] == 'Income' ? 'আয়' : 'ব্যয়';

        // Try to find the parsed account
        final parsedAccountName = result['account'] as String? ?? 'Cash';
        final matches = accountProvider.accounts.where((a) =>
            a.name.toLowerCase().contains(parsedAccountName.toLowerCase()) ||
            (parsedAccountName == 'Cash' && (a.name.contains('নগদ') || a.name.contains('Cash'))));
        if (matches.isNotEmpty) {
          _selectedAccount = matches.first;
          _toAccount = matches.first;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এআই ভয়েস সফলভাবে প্রসেস করা হয়েছে!')),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _taxController.dispose();
    for (var item in _splitItems) {
      item['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded, color: AppColors.primary),
            tooltip: 'OCR Receipt Scanner',
            onPressed: _scanReceiptOCR,
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.primary),
            tooltip: 'AI Voice Command',
            onPressed: _showVoiceCommandDialog,
          ),
          const SizedBox(width: 8),
        ],
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
            const SizedBox(height: 24),

            // Tax/VAT row
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.percent_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tax / VAT (%)',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: _taxController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('ট্যাক্স পরিমাণ', style: GoogleFonts.hindSiliguri(fontSize: 10, color: AppColors.textSecondary)),
                        Text('৳ ${_taxAmount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Type Selector
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Title/Category
            _buildFieldHeader('বিবরণ / ক্যাটাগরি'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'উদা: বাজার খরচ, স্যালারি',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              style: GoogleFonts.hindSiliguri(),
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

            // Attachments list
            _buildFieldHeader('রসিদ অ্যাটাচমেন্ট (Receipt Attachments)'),
            _buildAttachmentList(),
            const SizedBox(height: 32),

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
            controller: _amountController,
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
            return DropdownMenuItem(value: acc, child: Text(acc.name, style: GoogleFonts.hindSiliguri()));
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
                  ? AppColors.success.withOpacity(0.1) 
                  : AppColors.error.withOpacity(0.1),
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

  Widget _buildAttachmentList() {
    return Row(
      children: [
        ...List.generate(_attachmentPaths.length, (index) {
          final path = _attachmentPaths[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _removeAttachment(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: _pickAttachment,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
          ),
        ),
      ],
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
    final title = _titleController.text.trim();
    
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
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      final mappedType = _type == 'আয়' ? 'Income' : (_type == 'ব্যয়' ? 'Expense' : 'Transfer');

      // Anomaly Detection
      if (txProvider.checkAnomaly(_amount, title, mappedType)) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('অস্বাভাবিক লেনদেন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: AppColors.error)),
            content: Text('এই ক্যাটাগরিতে (৳$_amount) পরিমাণটি স্বাভাবিক গড়ের চেয়ে অনেক বেশি। আপনি কি নিশ্চিত যে এটি সঠিক?', style: GoogleFonts.hindSiliguri()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('বাতিল')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), 
                child: const Text('নিশ্চিত করুন', style: TextStyle(color: Colors.white))
              ),
            ],
          ),
        );
        if (confirm != true) return;
      }

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
        type: mappedType,
        category: title,
        isSplit: _isSplit,
        splitDetails: _isSplit ? splitMap : null,
        attachmentPaths: _attachmentPaths.isNotEmpty ? _attachmentPaths : null,
        taxPercentage: _taxPercentage > 0 ? _taxPercentage : null,
        taxAmount: _taxAmount > 0 ? _taxAmount : null,
      );

      await txProvider.addTransaction(
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
