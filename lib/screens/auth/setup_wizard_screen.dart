import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../home/dashboard_screen.dart';
import '../../models/account.dart';
import '../accounts/provider/account_provider.dart';
import '../settings/provider/settings_provider.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  String _selectedCurrency = 'BDT';
  String _selectedLanguage = 'bn';
  bool _isAdvancedMode = false;

  final TextEditingController _cashBalanceController =
      TextEditingController(text: '0');
  final TextEditingController _bankBalanceController =
      TextEditingController(text: '0');

  void _nextStep() async {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final accountProvider = Provider.of<AccountProvider>(
        context,
        listen: false,
      );
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );

      await settingsProvider.updateSettings(
        currency: _selectedCurrency,
        language: _selectedLanguage,
        isAdvancedMode: _isAdvancedMode,
        isFirstLaunch: false,
      );

      // Improved parsing to handle commas and other characters
      double parseBalance(String val) {
        return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      }

      double cashVal = parseBalance(_cashBalanceController.text);
      double bankVal = parseBalance(_bankBalanceController.text);

      // Always ensure default accounts are initialized with the entered balances
      await accountProvider.addAccount(
        Account(
          id: 'cash_001',
          name: 'নগদ (Cash)',
          type: 'Assets',
          balance: cashVal,
          iconName: 'cash_icon',
        ),
      );
      
      await accountProvider.addAccount(
        Account(
          id: 'bank_001',
          name: 'ব্যাংক (Bank)',
          type: 'Assets',
          balance: bankVal,
          iconName: 'bank_icon',
        ),
      );

      // Add MFS if it doesn't exist
      if (!accountProvider.accounts.any((a) => a.id == 'mfs_001')) {
        await accountProvider.addAccount(
          Account(
            id: 'mfs_001',
            name: 'মোবাইল ব্যাংকিং (MFS)',
            type: 'Assets',
            balance: 0.0,
            iconName: 'mfs_icon',
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cashBalanceController.dispose();
    _bankBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ধাপ ${_currentStep + 1} / 5',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildPreferencesStep(),
                  _buildModeSelectionStep(),
                  _buildMasterAccountsStep(),
                  _buildOpeningBalancesStep(),
                  _buildCompletionStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentStep == 4 ? 'ড্যাশবোর্ডে যান' : 'পরবর্তী',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return _buildStepLayout(
      title: 'পছন্দসই সেটিংস',
      subtitle: 'আপনার পছন্দের মুদ্রা এবং ভাষা নির্বাচন করুন।',
      icon: Icons.language_rounded,
      content: Column(
        children: [
          const SizedBox(height: 16),
          _buildDropdownItem(
            label: 'ভাষা (Language)',
            value: _selectedLanguage,
            items: {'bn': 'বাংলা', 'en': 'English'},
            onChanged: (val) => setState(() => _selectedLanguage = val!),
            isMap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelectionStep() {
    return _buildStepLayout(
      title: 'অ্যাকাউন্টিং মোড',
      subtitle: 'আপনার অভিজ্ঞতার ওপর ভিত্তি করে মোড বেছে নিন।',
      icon: Icons.tune_rounded,
      content: Column(
        children: [
          _buildModeCard(
            title: 'সিম্পল মোড (Simple Mode)',
            description: 'সহজ আয়-ব্যয় ট্র্যাকিং। যারা জটিল অ্যাকাউন্টিং এড়িয়ে চলতে চান।',
            icon: Icons.flash_on_rounded,
            isSelected: !_isAdvancedMode,
            onTap: () => setState(() => _isAdvancedMode = false),
          ),
          const SizedBox(height: 16),
          _buildModeCard(
            title: 'অ্যাডভান্সড মোড (Advanced Mode)',
            description: 'ডাবল-এন্ট্রি অ্যাকাউন্টিং। যেখানে ট্রানজ্যাকশন ডেবিট এবং ক্রেডিট হয়।',
            icon: Icons.account_balance_rounded,
            isSelected: _isAdvancedMode,
            onTap: () => setState(() => _isAdvancedMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningBalancesStep() {
    return _buildStepLayout(
      title: 'প্রারম্ভিক স্থিতি',
      subtitle: 'আপনার বর্তমান সম্পদের পরিমাণ দিয়ে শুরু করুন।',
      icon: Icons.account_balance_wallet_rounded,
      content: Column(
        children: [
          _buildBalanceInput(
            label: 'নগদ টাকা (Cash in hand)',
            controller: _cashBalanceController,
            icon: Icons.money_rounded,
          ),
          const SizedBox(height: 16),
          _buildBalanceInput(
            label: 'ব্যাংক ব্যালেন্স (Bank balance)',
            controller: _bankBalanceController,
            icon: Icons.food_bank_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMasterAccountsStep() {
    return _buildStepLayout(
      title: 'মাস্টার অ্যাকাউন্ট সেটআপ',
      subtitle: 'হিসাব শুরু করার জন্য আপনার মূল ক্যাটাগরিগুলো নির্বাচন করুন।',
      icon: Icons.account_tree_rounded,
      content: Column(
        children: [
          _buildSelectionItem('সম্পদ (Assets)', true),
          _buildSelectionItem('দায় (Liabilities)', true),
          _buildSelectionItem('মালিকানাধীন মূলধন (Equity)', true),
          _buildSelectionItem('আয় (Income)', true),
          _buildSelectionItem('ব্যয় (Expenses)', true),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    return _buildStepLayout(
      title: 'সব সেট!',
      subtitle: 'আপনার অ্যাকাউন্টগুলো তৈরি হয়ে গেছে। অ্যাপটি ব্যবহারের জন্য আপনি এখন প্রস্তুত।',
      icon: Icons.check_circle_outline_rounded,
      isCenter: true,
      content: Column(
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'অভিনন্দন!',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLayout({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
    bool isCenter = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: isCenter ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: isCenter ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 32),
          content,
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required String label,
    required String value,
    required dynamic items,
    required Function(String?) onChanged,
    bool isMap = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              items: (items as Map<String, String>)
                  .entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: GoogleFonts.hindSiliguri()),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  Text(description, style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixText: _selectedCurrency,
            hintText: '০.০০',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionItem(String text, bool isChecked) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: CheckboxListTile(
        title: Text(text, style: GoogleFonts.hindSiliguri()),
        value: isChecked,
        onChanged: (val) {},
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
