import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/billing/shop.dart';

class ShopProvider with ChangeNotifier {
  Shop? _shop;
  bool _isLoading = false;
  String? _error;

  Shop? get shop => _shop;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String shopKey = 'shop_details';

  ShopProvider() {
    loadShop();
  }

  Future<void> loadShop() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final box = Hive.box<Shop>('shop');
      final s = box.get(shopKey);
      if (s != null) {
        _shop = s;
      } else {
        _shop = const Shop(
          name: 'Rahim Enterprise',
          addressLine1: 'Mirpur,Dhaka',
          addressLine2: '356/221-2',
          phoneNumber: '+01*********',
          emailAddress: 'rahim226@gmail.com',
          footerText: 'Thank you, Visit again!!!',
        );
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateShop(Shop shop) async {
    _isLoading = true;
    notifyListeners();
    try {
      final box = Hive.box<Shop>('shop');
      await box.put(shopKey, shop);
      await loadShop();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
