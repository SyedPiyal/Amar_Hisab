import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../../providers/billing/product_provider.dart';
import '../billing/add_product_page.dart';
import 'add_item_screen.dart';
import '../../models/inventory_item.dart';

class InventoryScannerScreen extends StatefulWidget {
  const InventoryScannerScreen({super.key});

  @override
  State<InventoryScannerScreen> createState() => _InventoryScannerScreenState();
}

class _InventoryScannerScreenState extends State<InventoryScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _isScanned = true;
      final String barcode = barcodes.first.rawValue!;

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate();
      }

      if (!mounted) return;
      final productProvider = context.read<ProductProvider>();
      final product = await productProvider.getProductByBarcode(barcode);

      if (!mounted) return;

      if (product != null) {
        // Product Found: Navigate to AddItemScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemScreen(
              prefilledItem: {
                'name': product.name,
                'barcode': product.barcode,
                'stock': product.price.toString(), // Price mapped to Stock as requested
              },
            ),
          ),
        );
      } else {
        // Product Not Found: Navigate to AddProductPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddProductPage(initialBarcode: barcode),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('বারকোড স্ক্যান করুন', style: GoogleFonts.hindSiliguri()),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}
