import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/inventory_item.dart';

class InventoryProvider with ChangeNotifier {
  static const String _boxName = 'inventoryBox';
  List<InventoryItem> _items = [];

  List<InventoryItem> get items => _items;

  List<InventoryItem> get lowStockItems =>
      _items.where((item) => item.stockQuantity <= item.lowStockThreshold).toList();

  Future<void> loadItems() async {
    final box = await Hive.openBox<InventoryItem>(_boxName);
    _items = box.values.toList();
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    final box = await Hive.openBox<InventoryItem>(_boxName);
    await box.put(item.id, item);
    _items = box.values.toList();
    notifyListeners();
  }

  Future<void> updateItem(InventoryItem item) async {
    await item.save();
    notifyListeners();
  }

  Future<void> deleteItem(InventoryItem item) async {
    await item.delete();
    _items.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  Future<void> adjustStock(String itemId, double adjustment) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].stockQuantity += adjustment;
      _items[index].lastUpdated = DateTime.now();
      await _items[index].save();
      notifyListeners();
    }
  }
}
