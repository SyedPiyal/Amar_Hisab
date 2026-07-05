import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/billing/shop_provider.dart';
import '../../../models/billing/shop.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ShopProvider>();
      if (provider.shop != null) {
        _updateControllers(provider.shop!);
      }
    });
  }

  void _updateControllers(Shop shop) {
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
      _address1Controller.text = shop.addressLine1;
      _address2Controller.text = shop.addressLine2;
      _phoneController.text = shop.phoneNumber;
      _upiController.text = shop.upiId;
      _footerController.text = shop.footerText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        name: _nameController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text,
        phoneNumber: _phoneController.text,
        upiId: _upiController.text,
        footerText: _footerController.text,
      );

      context.read<ShopProvider>().updateShop(shop).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('দোকানের তথ্য সংরক্ষিত হয়েছে!', style: GoogleFonts.hindSiliguri()),
            backgroundColor: Colors.green));
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('দোকানের তথ্য', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.shop != null) {
            _updateControllers(provider.shop!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('সাধারণ তথ্য',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                      )),
                  const SizedBox(height: 5),
                  Text(
                    'এই তথ্যগুলি আপনার ডিজিটাল এবং প্রিন্ট করা রসিদে প্রদর্শিত হবে।',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  Text('দোকানের নাম', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'যেমন: কুইকমার্ট সুপারস্টোর',
                    validator: (val) => val == null || val.isEmpty ? 'প্রয়োজনীয়' : null,
                  ),
                  const SizedBox(height: 15),
                  Text('ঠিকানার লাইন ১', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _address1Controller,
                    hint: 'রাস্তা, এলাকা',
                    validator: (val) => val == null || val.isEmpty ? 'প্রয়োজনীয়' : null,
                  ),
                  const SizedBox(height: 15),
                  Text('ঠিকানার লাইন ২ (ঐচ্ছিক)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _address2Controller,
                    hint: 'শহর, পোস্টাল কোড',
                  ),
                  const SizedBox(height: 15),
                  Text('ফোন নম্বর', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '+৮৮০১৭XXXXXXXX',
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty ? 'প্রয়োজনীয়' : null,
                  ),
                  const SizedBox(height: 15),
                  Text('ইউপিআই আইডি (UPI ID)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _upiController,
                    hint: 'example@upi',
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('রসিদের ফুটার টেক্সট', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                      Text('সর্বোচ্চ ৬০ অক্ষর',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _footerController,
                    hint: 'ধন্যবাদ, আবার আসবেন!!!',
                    maxLines: 2,
                    maxLength: 60,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _saveShop,
                    icon: const Icon(Icons.save),
                    label: Text('তথ্য সংরক্ষণ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      style: GoogleFonts.hindSiliguri(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey[400]),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
