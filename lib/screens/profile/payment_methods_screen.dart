import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'পেমেন্ট মেথড',
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
          Text(
            'সংরক্ষিত কার্ড এবং অ্যাকাউন্ট',
            style: GoogleFonts.hindSiliguri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Card 1: Visa
          _buildCreditCard(
            bankName: 'City Bank',
            cardNumber: '**** **** **** ৪৩২১',
            expiry: '১২/২৫',
            cardType: 'VISA',
            colors: [const Color(0xff090979), const Color(0xff00d4ff)],
          ),
          const SizedBox(height: 16),
          
          // Mobile Banking Section
          Text(
            'মোবাইল ব্যাংকিং',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileBankingItem('bKash', '০১৭** *** ৬৭৮', Colors.pink, Icons.account_balance_wallet_rounded),
          _buildMobileBankingItem('Nagad', '০১৫** *** ১২৩', Colors.orange, Icons.account_balance_wallet_outlined),
          
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'নতুন মেথড যোগ করুন',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCreditCard({
    required String bankName,
    required String cardNumber,
    required String expiry,
    required String cardType,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bankName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                cardType,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            cardNumber,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRY',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    expiry,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.contactless_rounded, color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBankingItem(String name, String number, Color color, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          number,
          style: GoogleFonts.inter(fontSize: 12),
        ),
        trailing: const Icon(Icons.more_vert_rounded),
      ),
    );
  }
}
