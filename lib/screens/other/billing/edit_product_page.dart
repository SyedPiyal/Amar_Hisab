import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/billing/product_provider.dart';
import '../../../models/billing/product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _barcode;
  late double _price;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _barcode = widget.product.barcode;
    _price = widget.product.price;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = context.read<ProductProvider>();
      final existingProduct = provider.products.where((p) => p.barcode == _barcode && p.id != widget.product.id).firstOrNull;

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product with barcode "$_barcode" already exists!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        barcode: _barcode,
        price: _price,
      );

      provider.updateProduct(updatedProduct).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Barcode', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _barcode,
                    decoration: const InputDecoration(
                      hintText: 'Enter barcode',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (value) => _barcode = value!,
                  ),
                  const SizedBox(height: 24),
                  const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Basmati Rice',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  const Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _price.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                       if(val == null || val.isEmpty) return 'Required';
                       if(double.tryParse(val) == null) return 'Invalid price';
                       return null;
                    },
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
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
