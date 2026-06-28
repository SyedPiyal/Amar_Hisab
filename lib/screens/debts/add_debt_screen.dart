import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'provider/debt_provider.dart';
import '../accounts/provider/account_provider.dart';
import '../../models/account.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  String _personName = '';
  double _amount = 0.0;
  String _type = 'Receivable'; // 'Receivable' or 'Payable'
  Account? _selectedAccount;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pickContact() {
    showDialog(
      context: context,
      builder: (context) {
        final mockContacts = [
          {'name': 'করিম চাচা', 'phone': '01712345678'},
          {'name': 'রহিম ভাই', 'phone': '01887654321'},
          {'name': 'রশিদ সাহেব', 'phone': '01911223344'},
          {'name': 'আব্দুল্লাহ ভাই', 'phone': '01555667788'},
        ];
        return AlertDialog(
          title: Text('ফোনবুক থেকে নির্বাচন করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mockContacts.length,
              itemBuilder: (context, index) {
                final c = mockContacts[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(c['name']!, style: GoogleFonts.hindSiliguri()),
                  subtitle: Text(c['phone']!, style: GoogleFonts.inter()),
                  onTap: () {
                    setState(() {
                      _nameController.text = c['name']!;
                      _phoneController.text = c['phone']!;
                      _personName = c['name']!;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? (_dueDate ?? DateTime.now()) : _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'নতুন দেনা-পাওনা যোগ করুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector
              Row(
                children: [
                  Expanded(child: _buildTypeButton('Receivable', 'পাওনা (I lent money)', _type == 'Receivable')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTypeButton('Payable', 'দেনা (I borrowed)', _type == 'Payable')),
                ],
              ),
              const SizedBox(height: 32),

              _buildFieldHeader('ব্যক্তির নাম'),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'উদা: রহিম ভাই',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.contact_phone_outlined, color: AppColors.primary),
                    onPressed: _pickContact,
                  ),
                ),
                style: GoogleFonts.hindSiliguri(),
                validator: (val) => val == null || val.isEmpty ? 'নাম দিন' : null,
                onChanged: (val) => _personName = val,
              ),
              const SizedBox(height: 24),

              _buildFieldHeader('মোবাইল নম্বর (SMS তগাদার জন্য)'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'উদা: 017XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_android_rounded),
                ),
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 24),

              _buildFieldHeader('টাকার পরিমাণ'),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '৳ ০.০০',
                  prefixIcon: const Icon(Icons.money_rounded),
                  suffixText: 'BDT',
                  suffixStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                style: GoogleFonts.inter(),
                validator: (val) => val == null || double.tryParse(val) == null || double.parse(val) <= 0 ? 'সঠিক পরিমাণ দিন' : null,
                onChanged: (val) => _amount = double.tryParse(val) ?? 0.0,
              ),
              const SizedBox(height: 24),

              _buildFieldHeader('অ্যাকাউন্ট সিলিন করুন (ঐচ্ছিক)'),
              Consumer<AccountProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<Account>(
                    decoration: const InputDecoration(
                      hintText: 'টাকার উৎস/গন্তব্য',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    items: provider.accounts.map((acc) {
                      return DropdownMenuItem(value: acc, child: Text(acc.name, style: GoogleFonts.hindSiliguri()));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedAccount = val),
                  );
                },
              ),
              const SizedBox(height: 24),

              _buildFieldHeader('তারিখ'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                title: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: GoogleFonts.inter(),
                ),
                onTap: () => _selectDate(context, false),
              ),
              const Divider(),
              
              _buildFieldHeader('পরিশোধের সম্ভাব্য তারিখ'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note_rounded, color: AppColors.secondary),
                title: Text(
                  _dueDate == null ? 'সিলেক্ট করুন' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  style: GoogleFonts.hindSiliguri(color: _dueDate == null ? AppColors.textSecondary : AppColors.textPrimary),
                ),
                onTap: () => _selectDate(context, true),
              ),
              const Divider(),

              _buildFieldHeader('নোট (যদি থাকে)'),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'অতিরিক্ত তথ্য...',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                style: GoogleFonts.hindSiliguri(),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'সংরক্ষণ করুন',
                    style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildTypeButton(String type, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? (type == 'Receivable' ? AppColors.success : AppColors.error) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? (type == 'Receivable' ? AppColors.success : AppColors.error) : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<DebtProvider>(context, listen: false).addDebt(
        personName: _nameController.text,
        amount: _amount,
        type: _type,
        date: _date,
        dueDate: _dueDate,
        note: _noteController.text,
        account: _selectedAccount,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সফলভাবে যোগ করা হয়েছে')),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
