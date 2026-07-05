import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'billing_page.dart';
import 'product_list_page.dart';
import 'shop_details_page.dart';
import '../../../theme/app_colors.dart';

class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'অ্যাডভান্সড বিলিং এবং পিওএস',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection('পিওএস সিস্টেম', [
            _buildMenuItem(
              context,
              'নতুন বিক্রি / চেকআউট',
              Icons.point_of_sale_rounded,
              const BillingPage(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildMenuSection('ব্যবস্থাপনা', [
            _buildMenuItem(
              context,
              'পণ্য ব্যবস্থাপনা',
              Icons.inventory_2_outlined,
              const ProductListPage(),
            ),
            _buildMenuItem(
              context,
              'দোকানের তথ্য',
              Icons.store_outlined,
              const ShopDetailsPage(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Card(child: Column(children: items)),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget target,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: GoogleFonts.hindSiliguri()),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => target));
      },
    );
  }
}
