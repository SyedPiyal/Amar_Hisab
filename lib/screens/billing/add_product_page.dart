import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/billing/product_provider.dart';
import '../../models/billing/product.dart';

class AddProductPage extends StatefulWidget {
  final String? initialBarcode;
  const AddProductPage({super.key, this.initialBarcode});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  late String _barcode;
  double _price = 0.0;

  @override
  void initState() {
    super.initState();
    _barcode = widget.initialBarcode ?? '';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = context.read<ProductProvider>();
      final existingProduct = provider.products.where((p) => p.barcode == _barcode).firstOrNull;

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('বারকোড "$_barcode" সহ পণ্য ইতিমধ্যে বিদ্যমান!', style: GoogleFonts.hindSiliguri()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: _barcode,
        price: _price,
      );

      provider.addProduct(product).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('পণ্য যোগ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('বারকোড', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_barcode),
                          initialValue: _barcode,
                          style: GoogleFonts.hindSiliguri(),
                          decoration: InputDecoration(
                            hintText: 'স্ক্যান করুন বা বারকোড দিন',
                            hintStyle: GoogleFonts.hindSiliguri(),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'প্রয়োজনীয়' : null,
                          onSaved: (value) => _barcode = value!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('পণ্যের নাম', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: GoogleFonts.hindSiliguri(),
                    decoration: InputDecoration(
                      hintText: 'যেমন: বাসমতি চাল',
                      hintStyle: GoogleFonts.hindSiliguri(),
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val == null || val.isEmpty ? 'প্রয়োজনীয়' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  Text('মূল্য', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '০.০০',
                      prefixText: '৳ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                       if(val == null || val.isEmpty) return 'প্রয়োজনীয়';
                       if(double.tryParse(val) == null) return 'সঠিক মূল্য দিন';
                       return null;
                    },
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add_circle),
                      label: Text('পণ্য যোগ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }
}
