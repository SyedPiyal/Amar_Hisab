import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../providers/billing/shop_provider.dart';
import '../../../providers/billing/billing_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          context.read<BillingProvider>().clearCart();
          Navigator.pop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('চেকআউট', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.chevron_left, size: 28, color: Theme.of(context).primaryColor),
              onPressed: () {
                context.read<BillingProvider>().clearCart();
                Navigator.pop(context);
              },
            ),
          ),
          body: Consumer<BillingProvider>(
            builder: (context, billingState, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (billingState.printSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('সফলভাবে প্রিন্ট করা হয়েছে', style: GoogleFonts.hindSiliguri()),
                      backgroundColor: Colors.green));
                }
              });

              return Consumer<ShopProvider>(
                  builder: (context, shopState, child) {
                String upiId = shopState.shop?.upiId ?? '';
                String shopName = shopState.shop?.name ?? 'Shop';

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside: BorderSide(color: borderColor),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(bottom: BorderSide(color: borderColor)),
                                      ),
                                      children: [
                                        _buildHeaderCell('পণ্যের নাম', TextAlign.left),
                                        _buildHeaderCell('মূল্য', TextAlign.right),
                                        _buildHeaderCell('মোট', TextAlign.right),
                                      ],
                                    ),
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(
                                        children: [
                                          _buildDataCell('${item.quantity} x ${item.product.name}', TextAlign.left),
                                          _buildDataCell('৳${item.product.price.toStringAsFixed(2)}', TextAlign.right, isSubtitle: true),
                                          _buildDataCell('৳${item.total.toStringAsFixed(2)}', TextAlign.right, isBold: true),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(24), right: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                upiId.isNotEmpty
                                    ? Column(
                                        children: [
                                          Text('পেমেন্ট করতে স্ক্যান করুন', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: 180,
                                            height: 180,
                                            child: PrettyQrView.data(
                                              data: 'upi://pay?pa=$upiId&pn=$shopName&am=${billingState.totalAmount.toStringAsFixed(2)}&cu=INR',
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('সর্বমোট', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                                    Text('৳${billingState.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (shopState.shop != null) {
                                    billingState.printReceipt(
                                        shopName: shopState.shop!.name,
                                        address1: shopState.shop!.addressLine1,
                                        address2: shopState.shop!.addressLine2,
                                        phone: shopState.shop!.phoneNumber,
                                        footer: shopState.shop!.footerText);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('দোকানের তথ্য লোড করা হয়নি', style: GoogleFonts.hindSiliguri()), backgroundColor: Colors.red));
                                  }
                                },
                                label: Text('রসিদ প্রিন্ট করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                                icon: const Icon(Icons.print),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ));
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(text, textAlign: align, style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildDataCell(String text, TextAlign align, {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(text, textAlign: align, style: GoogleFonts.hindSiliguri(fontSize: isSubtitle ? 12 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isSubtitle ? Colors.grey[500] : Colors.black87)),
    );
  }
}
