import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/billing/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final box = Hive.box<Product>('products');
      _products = box.values.toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final box = Hive.box<Product>('products');
      return box.values.firstWhere((p) => p.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    try {
      final box = Hive.box<Product>('products');
      await box.put(product.id, product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    try {
      final box = Hive.box<Product>('products');
      await box.put(product.id, product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final box = Hive.box<Product>('products');
      await box.delete(id);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
