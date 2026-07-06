import 'package:flutter/foundation.dart';
import '../../models/billing/cart_item.dart';
import '../../models/billing/product.dart';
import '../../services/billing/printer_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BillingProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isPrinting = false;
  bool _printSuccess = false;
  String? _error;

  List<CartItem> get cartItems => _cartItems;
  bool get isPrinting => _isPrinting;
  bool get printSuccess => _printSuccess;
  String? get error => _error;

  double get totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + item.total);
  }

  void scanBarcode(String barcode, Product? product) {
    if (product == null) {
      _error = 'Product not found: $barcode';
      notifyListeners();
    } else {
      addProductToCart(product);
    }
  }

  void addProductToCart(Product product) {
    _error = null;
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeProductFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProductFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _error = null;
    _printSuccess = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required String footer,
  }) async {
    final printerHelper = PrinterHelper();

    // Auto-connect if not connected
    if (!printerHelper.isConnected) {
      final settings = Hive.box('settings');
      final type = settings.get('printer_type'); // 'bluetooth' or 'wifi'
      
      bool connected = false;
      
      if (type == 'bluetooth') {
        final savedMac = settings.get('printer_mac');
        if (savedMac != null) {
          _isPrinting = true;
          notifyListeners();
          connected = await printerHelper.connectBluetooth(savedMac);
        }
      } else if (type == 'wifi') {
        final savedIp = settings.get('printer_ip');
        if (savedIp != null) {
          _isPrinting = true;
          notifyListeners();
          connected = await printerHelper.connectWifi(savedIp);
        }
      }

      if (!connected && type != null) {
        _isPrinting = false;
        _error = 'প্রিন্টারের সাথে সংযোগ করা সম্ভব হয়নি। সংযোগ পরীক্ষা করুন।';
        notifyListeners();
        return;
      } else if (type == null) {
        _error = 'প্রিন্টার সংযুক্ত নেই। অনুগ্রহ করে সেটিংস থেকে প্রিন্টার যুক্ত করুন।';
        notifyListeners();
        return;
      }
    }

    _isPrinting = true;
    _printSuccess = false;
    _error = null;
    notifyListeners();

    try {
      final items = _cartItems.map((item) => {
        'name': item.product.name,
        'qty': item.quantity,
        'price': item.product.price,
        'total': item.total,
      }).toList();

      await printerHelper.printReceipt(
        shopName: shopName,
        address1: address1,
        address2: address2,
        phone: phone,
        items: items,
        total: totalAmount,
        footer: footer,
      );

      _isPrinting = false;
      _printSuccess = true;
      notifyListeners();
    } catch (e) {
      _isPrinting = false;
      _error = 'প্রিন্ট করতে সমস্যা হয়েছে: $e';
      notifyListeners();
    }
  }
}
