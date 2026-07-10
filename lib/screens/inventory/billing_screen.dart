// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../../theme/app_colors.dart';
// import '../../models/inventory_item.dart';
// import 'inventory_provider.dart';
//
// class BillingScreen extends StatefulWidget {
//   const BillingScreen({super.key});
//
//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }
//
// class _BillingScreenState extends State<BillingScreen> {
//   final List<BillingItem> _billedItems = [];
//   final TextEditingController _barcodeController = TextEditingController();
//
//   double get _totalAmount => _billedItems.fold(0, (sum, item) => sum + item.total);
//
//   void _addItemByBarcode(String barcode) {
//     final inventory = Provider.of<InventoryProvider>(context, listen: false).items;
//     try {
//       final item = inventory.firstWhere(
//         (element) => element.barcode == barcode,
//       );
//       _addItemToBill(item);
//     } catch (e) {
//       throw Exception('Product not found');
//     }
//   }
//
//   void _addItemToBill(InventoryItem item) {
//     setState(() {
//       final index = _billedItems.indexWhere((bi) => bi.item.id == item.id);
//       if (index != -1) {
//         _billedItems[index].quantity++;
//       } else {
//         _billedItems.add(BillingItem(item: item));
//       }
//     });
//   }
//
//   void _showScanDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('বারকোড স্ক্যান (সিমুলেশন)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('পন্যের বারকোড বা QR কোড টাইপ করুন:', style: GoogleFonts.hindSiliguri()),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _barcodeController,
//               decoration: const InputDecoration(
//                 hintText: 'বারকোড লিখুন (উদা: 12345)',
//                 border: OutlineInputBorder(),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//               autofocus: true,
//               keyboardType: TextInputType.text,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               _barcodeController.clear();
//               Navigator.pop(context);
//             },
//             child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (_barcodeController.text.trim().isEmpty) return;
//               try {
//                 _addItemByBarcode(_barcodeController.text.trim());
//                 _barcodeController.clear();
//                 Navigator.pop(context);
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('এই বারকোডের কোন পণ্য পাওয়া যায়নি!'),
//                     backgroundColor: AppColors.error,
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//             child: Text('যোগ করুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           'বিলিং ও পিওএস',
//           style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _billedItems.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(32),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.1),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(Icons.qr_code_scanner_rounded, size: 80, color: AppColors.primary),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           'বিলিং শুরু করতে পণ্য স্ক্যান করুন',
//                           style: GoogleFonts.hindSiliguri(
//                             fontSize: 18,
//                             color: AppColors.textPrimary,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'আপনার ইনভেন্টরি থেকে পণ্য যোগ হবে',
//                           style: GoogleFonts.hindSiliguri(
//                             fontSize: 14,
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _billedItems.length,
//                     itemBuilder: (context, index) {
//                       final billingItem = _billedItems[index];
//                       return Card(
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           side: BorderSide(color: AppColors.border.withOpacity(0.5)),
//                         ),
//                         margin: const EdgeInsets.only(bottom: 12),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 56,
//                                 height: 56,
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primary.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       billingItem.item.name,
//                                       style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
//                                     ),
//                                     Text(
//                                       '৳${billingItem.item.salePrice.toStringAsFixed(2)} x ${billingItem.quantity} ${billingItem.item.unit}',
//                                       style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     '৳${billingItem.total.toStringAsFixed(2)}',
//                                     style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
//                                   ),
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       IconButton(
//                                         visualDensity: VisualDensity.compact,
//                                         icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.error),
//                                         onPressed: () {
//                                           setState(() {
//                                             if (billingItem.quantity > 1) {
//                                               billingItem.quantity--;
//                                             } else {
//                                               _billedItems.removeAt(index);
//                                             }
//                                           });
//                                         },
//                                       ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                                         child: Text('${billingItem.quantity}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
//                                       ),
//                                       IconButton(
//                                         visualDensity: VisualDensity.compact,
//                                         icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.success),
//                                         onPressed: () {
//                                           setState(() {
//                                             billingItem.quantity++;
//                                           });
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 15,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'সর্বমোট (Total):',
//                       style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '৳ ${_totalAmount.toStringAsFixed(2)}',
//                       style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _showScanDialog,
//                         icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
//                         label: Text('স্ক্যান করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                           elevation: 0,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           context: context,
//                           isScrollControlled: true,
//                           backgroundColor: Colors.transparent,
//                           builder: (context) => _ProductSelectionSheet(
//                             onSelected: (item) {
//                               _addItemToBill(item);
//                               Navigator.pop(context);
//                             },
//                           ),
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: const Icon(Icons.list_alt_rounded, color: AppColors.primary, size: 28),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _billedItems.isEmpty ? null : () {
//                       // Implementation for finishing bill
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('বিল সফলভাবে সম্পন্ন হয়েছে!'),
//                           backgroundColor: AppColors.success,
//                         ),
//                       );
//                       setState(() => _billedItems.clear());
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.success,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       elevation: 0,
//                       disabledBackgroundColor: Colors.grey[300],
//                     ),
//                     child: Text('পেমেন্ট ও রসিদ তৈরি', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class BillingItem {
//   final InventoryItem item;
//   int quantity;
//
//   BillingItem({required this.item, this.quantity = 1});
//
//   double get total => item.salePrice * quantity;
// }
//
// class _ProductSelectionSheet extends StatelessWidget {
//   final Function(InventoryItem) onSelected;
//
//   const _ProductSelectionSheet({required this.onSelected});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       padding: const EdgeInsets.all(24),
//       height: MediaQuery.of(context).size.height * 0.75,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'পণ্য নির্বাচন করুন',
//                 style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
//             ],
//           ),
//           const Divider(),
//           const SizedBox(height: 8),
//           Expanded(
//             child: Consumer<InventoryProvider>(
//               builder: (context, provider, _) {
//                 final inventory = provider.items;
//                 if (inventory.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'ইনভেন্টরিতে কোন পণ্য নেই।\nপ্রথমে পণ্য যোগ করুন।',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
//                     ),
//                   );
//                 }
//                 return ListView.builder(
//                   itemCount: inventory.length,
//                   itemBuilder: (context, index) {
//                     final item = inventory[index];
//                     return ListTile(
//                       contentPadding: const EdgeInsets.symmetric(vertical: 4),
//                       leading: CircleAvatar(
//                         backgroundColor: AppColors.primary.withOpacity(0.1),
//                         child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
//                       ),
//                       title: Text(item.name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
//                       subtitle: Text('স্টক: ${item.stockQuantity} ${item.unit} | মূল্য: ৳${item.salePrice}', style: GoogleFonts.inter(fontSize: 12)),
//                       trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
//                       onTap: () => onSelected(item),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
