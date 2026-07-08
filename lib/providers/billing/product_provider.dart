import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/billing/product.dart';
import '../../services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  static const String _boxName = 'products';
  static const String _globalCollection = 'global_products';
  
  final FirestoreService _firestoreService = FirestoreService();
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
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox<Product>(_boxName);
      }
      final box = Hive.box<Product>(_boxName);
      _products = box.values.toList();
      
      // Fetch global products from Firestore in the background
      _syncGlobalProducts();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncGlobalProducts() async {
    try {
      final globalData = await _firestoreService.fetchGlobalCollection(collection: _globalCollection);
      if (globalData.isNotEmpty) {
        final box = Hive.box<Product>(_boxName);
        for (var data in globalData) {
          final String barcode = data['barcode'] ?? '';
          if (barcode.isEmpty) continue;

          // Prevent local duplicates: check if we already have this barcode
          final existing = box.values.where((p) => p.barcode == barcode).firstOrNull;
          
          final product = Product(
            id: existing?.id ?? data['id'] ?? barcode, // Use existing ID if available
            name: data['name'] ?? '',
            barcode: barcode,
            price: (data['price'] ?? 0).toDouble(),
            stock: data['stock'] ?? 0,
          );
          
          await box.put(product.id, product);
        }
        _products = box.values.toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing global products: $e');
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final box = Hive.box<Product>(_boxName);
      return box.values.firstWhere((p) => p.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    try {
      final box = Hive.box<Product>(_boxName);
      await box.put(product.id, product);
      
      // Upload to global Firestore using barcode as documentId to prevent duplicates
      await _firestoreService.saveGlobalRecord(
        collection: _globalCollection,
        documentId: product.barcode,
        data: _productToMap(product),
      );

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
      final box = Hive.box<Product>(_boxName);
      await box.put(product.id, product);

      // Update global Firestore using barcode as documentId
      await _firestoreService.saveGlobalRecord(
        collection: _globalCollection,
        documentId: product.barcode,
        data: _productToMap(product),
      );

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
      final box = Hive.box<Product>(_boxName);
      await box.delete(id);
      
      // Note: We do not delete from global Firestore to prevent individual users 
      // from removing products for the entire community.
      
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'barcode': product.barcode,
      'price': product.price,
      'stock': product.stock,
    };
  }
}
