import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/inventory_item.dart';
import '../services/sync_service.dart';

class InventoryProvider with ChangeNotifier {
  static const String _boxName = 'inventoryBox';
  List<InventoryItem> _items = [];
  final SyncService _syncService = SyncService();

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

    await _syncService.enqueueOperation(
      _boxName,
      item.id,
      'CREATE',
      _itemToMap(item),
    );
  }

  Future<void> updateItem(InventoryItem item) async {
    await item.save();
    notifyListeners();

    await _syncService.enqueueOperation(
      _boxName,
      item.id,
      'UPDATE',
      _itemToMap(item),
    );
  }

  Future<void> deleteItem(InventoryItem item) async {
    final itemId = item.id;
    await item.delete();
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();

    await _syncService.enqueueOperation(
      _boxName,
      itemId,
      'DELETE',
      null,
    );
  }

  Future<void> adjustStock(String itemId, double adjustment) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].stockQuantity += adjustment;
      _items[index].lastUpdated = DateTime.now();
      await _items[index].save();
      notifyListeners();

      await _syncService.enqueueOperation(
        _boxName,
        itemId,
        'UPDATE',
        _itemToMap(_items[index]),
      );
    }
  }

  Map<String, dynamic> _itemToMap(InventoryItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'category': item.category,
      'stockQuantity': item.stockQuantity,
      'unit': item.unit,
      'unitPrice': item.unitPrice,
      'lowStockThreshold': item.lowStockThreshold,
      'lastUpdated': item.lastUpdated.toIso8601String(),
    };
  }
}
