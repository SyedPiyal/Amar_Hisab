import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_item.dart';
import 'add_item_screen.dart';
import '../transactions/add_transaction_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ইনভেন্টরি বা স্টক',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              // TODO: Implement Barcode Scanner
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('স্ক্যানার শীঘ্রই আসছে...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, provider, child) {
                final filteredItems = provider.items.where((item) {
                  return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (item.barcode?.contains(_searchQuery) ?? false);
                }).toList();

                if (filteredItems.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildInventoryItemCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'নতুন আইটেম',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'আইটেমের নাম বা বারকোড খুঁজুন...',
          hintStyle: GoogleFonts.hindSiliguri(),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'কোন আইটেম পাওয়া যায়নি',
            style: GoogleFonts.hindSiliguri(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemCard(InventoryItem item) {
    final bool isLowStock = item.stockQuantity <= item.lowStockThreshold;
    final currencyFormat = NumberFormat.currency(locale: 'bn_BD', symbol: '৳', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen(item: item)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isLowStock ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: isLowStock ? Colors.red : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'বিক্রয় মূল্য: ${currencyFormat.format(item.salePrice)}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.stockQuantity} ${item.unit}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: isLowStock ? Colors.red : AppColors.textPrimary,
                        ),
                      ),
                      if (isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'অল্প স্টক',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTransactionScreen(
                            initialInventoryItem: item,
                            initialType: 'ব্যয়',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: Text(
                      'স্টক যোগ',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTransactionScreen(
                            initialInventoryItem: item,
                            initialType: 'আয়',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sell_outlined, size: 18),
                    label: Text(
                      'বিক্রি',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(foregroundColor: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
