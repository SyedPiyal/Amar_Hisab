import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../theme/app_colors.dart';
import '../../models/inventory_item.dart';
import 'inventory_provider.dart';
import 'inventory_scanner_screen.dart';

class AddItemScreen extends StatefulWidget {
  final InventoryItem? item;
  final Map<String, String>? prefilledItem;

  const AddItemScreen({super.key, this.item, this.prefilledItem});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  
  String _selectedUnit = 'Piece';
  final List<String> _units = ['Piece', 'KG', 'Litre', 'Packet', 'Box', 'Dozen'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item?.name ?? widget.prefilledItem?['name'] ?? '',
    );
    _barcodeController = TextEditingController(
      text: widget.item?.barcode ?? widget.prefilledItem?['barcode'] ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: widget.item?.purchasePrice.toString() ?? '',
    );
    _salePriceController = TextEditingController(
      text: widget.item?.salePrice.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.item?.stockQuantity.toString() ?? '',
    );
    _thresholdController = TextEditingController(
      text: widget.item?.lowStockThreshold.toString() ?? '5.0',
    );
    if (widget.item != null) {
      _selectedUnit = widget.item!.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      
      final newItem = InventoryItem(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        purchasePrice: double.parse(_purchasePriceController.text),
        salePrice: double.parse(_salePriceController.text),
        stockQuantity: double.parse(_stockController.text),
        unit: _selectedUnit,
        lowStockThreshold: double.parse(_thresholdController.text),
        lastUpdated: DateTime.now(),
      );

      if (widget.item == null) {
        provider.addItem(newItem);
      } else {
        provider.updateItem(newItem);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'আইটেম এডিট করুন' : 'নতুন আইটেম যোগ করুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('সাধারণ তথ্য'),
              _buildTextField(
                controller: _nameController,
                label: 'আইটেমের নাম',
                hint: 'যেমন: চাল, ডাল, সাবান',
                validator: (v) => v!.isEmpty ? 'নাম প্রয়োজন' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _barcodeController,
                      label: 'বারকোড (ঐচ্ছিক)',
                      hint: 'স্ক্যান বা টাইপ করুন',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: IconButton.filledTonal(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InventoryScannerScreen()),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('মূল্য নির্ধারণ'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _purchasePriceController,
                      label: 'ক্রয় মূল্য',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'প্রয়োজন' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _salePriceController,
                      label: 'বিক্রয় মূল্য',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'প্রয়োজন' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('স্টক ও ইউনিট'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'বর্তমান স্টক',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'প্রয়োজন' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ইউনিট',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedUnit,
                              isExpanded: true,
                              items: _units.map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u, style: GoogleFonts.inter()),
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedUnit = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _thresholdController,
                label: 'লো-স্টক এলার্ট লিমিট',
                hint: '5.0',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'প্রয়োজন' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'আপডেট করুন' : 'সেভ করুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Provider.of<InventoryProvider>(context, listen: false).deleteItem(widget.item!);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    label: Text(
                      'আইটেমটি মুছে ফেলুন',
                      style: GoogleFonts.hindSiliguri(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textSecondary.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
