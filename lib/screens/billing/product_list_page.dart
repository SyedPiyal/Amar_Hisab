import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/billing/product_provider.dart';
import '../../../models/billing/product.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'পণ্য ব্যবস্থাপনা',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.hindSiliguri(),
                        decoration: InputDecoration(
                          hintText: 'খুঁজুন বা বারকোড দিন',
                          hintStyle: GoogleFonts.hindSiliguri(),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.products.isEmpty) {
                  if (provider.error != null) {
                    return Center(
                      child: Text(
                        'ত্রুটি: ${provider.error}',
                        style: GoogleFonts.hindSiliguri(),
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      'কোনো পণ্য পাওয়া যায়নি। যোগ করুন!',
                      style: GoogleFonts.hindSiliguri(),
                    ),
                  );
                }

                final filteredProducts = provider.products
                    .where(
                      (product) =>
                          product.name.toLowerCase().contains(_searchQuery) ||
                          product.barcode.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'আপনার অনুসন্ধানের সাথে কোনো পণ্য মিলছে না।',
                      style: GoogleFonts.hindSiliguri(),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 100,
                  ),
                  itemCount: filteredProducts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.hindSiliguri(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.hindSiliguri(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditProductPage(product: product),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _confirmDelete(context, product),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddProductPage()),
        ),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: Text(
            'পণ্য মুছে ফেলুন',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'আপনি কি নিশ্চিত যে আপনি ${product.name} মুছে ফেলতে চান?',
            style: GoogleFonts.hindSiliguri(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: Text('বাতিল', style: GoogleFonts.hindSiliguri()),
            ),
            TextButton(
              onPressed: () {
                context.read<ProductProvider>().deleteProduct(product.id);
                Navigator.pop(innerContext);
              },
              child: Text(
                'মুছে ফেলুন',
                style: GoogleFonts.hindSiliguri(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
