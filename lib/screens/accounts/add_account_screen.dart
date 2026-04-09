import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../providers/account_provider.dart';
import '../../models/account.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedType = 'Assets';
  Account? _selectedParentAccount;

  final Map<String, String> _typeDisplayNames = {
    'Assets': 'সম্পদ (Assets)',
    'Liabilities': 'দায় (Liabilities)',
    'Equity': 'মালিকানাধীন মূলধন (Equity)',
    'Income': 'আয় (Income)',
    'Expenses': 'ব্যয় (Expenses)',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'নতুন অ্যাকাউন্ট যোগ করুন',
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
            // Account Name
            _buildFieldHeader('অ্যাকাউন্টের নাম'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'উদা: ব্যাংক এশিয়া'),
            ),
            const SizedBox(height: 24),

            // Account Type
            _buildFieldHeader('অ্যাকাউন্টের ধরন'),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _typeDisplayNames.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: GoogleFonts.hindSiliguri(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    // Reset parent if type changes, or filter parent by type
                    _selectedParentAccount = null;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Parent Account (Hierarchy)
            _buildFieldHeader('প্যারেন্ট অ্যাকাউন্ট (ঐচ্ছিক)'),
            Consumer<AccountProvider>(
              builder: (context, provider, _) {
                final potentialParents = provider.accounts
                    .where((acc) => acc.type == _selectedType)
                    .toList();
                
                return DropdownButtonFormField<Account>(
                  value: _selectedParentAccount,
                  decoration: const InputDecoration(
                    hintText: 'কোনও প্যারেন্ট নেই',
                  ),
                  items: [
                    const DropdownMenuItem<Account>(
                      value: null,
                      child: Text('কোনও প্যারেন্ট নেই'),
                    ),
                    ...potentialParents.map(
                      (acc) => DropdownMenuItem(
                        value: acc,
                        child: Text(acc.name, style: GoogleFonts.hindSiliguri()),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedParentAccount = value);
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Initial Balance
            _buildFieldHeader('শুরুর ব্যালেন্স (Initial Balance)'),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '৳ ০.০০',
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onSave,
                child: Text(
                  'সংরক্ষণ করুন',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500),
      ),
    );
  }

  void _onSave() async {
    if (_nameController.text.isEmpty || _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সব তথ্য দিন')),
      );
      return;
    }

    double? balance = double.tryParse(_balanceController.text);
    if (balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বৈধ ব্যালেন্স লিখুন')),
      );
      return;
    }

    await Provider.of<AccountProvider>(
      context,
      listen: false,
    ).addAccount(
      Account(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        balance: balance,
        iconName: 'account_balance',
        parentId: _selectedParentAccount?.id,
      ),
    );

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অ্যাকাউন্ট যোগ করা হয়েছে')),
      );
    }
  }
}
