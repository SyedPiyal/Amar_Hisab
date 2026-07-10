import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/inventory_item.dart';
import '../../services/sync_service.dart';
import '../../services/firestore_service.dart';
import '../../services/sync_mapper.dart';

class InventoryProvider with ChangeNotifier {
  static const String _baseBoxName = 'inventoryBox';
  List<InventoryItem> _items = [];
  final SyncService _syncService = SyncService();
  final FirestoreService _firestoreService = FirestoreService();

  InventoryProvider() {
    loadItems();
    // Listen for user changes to reload data
    _syncService.onUidChanged.listen((uid) {
      loadItems();
    });
  }

  String get _scopedBoxName {
    final uid = _syncService.currentUid;
    return uid != null ? '${_baseBoxName}_$uid' : '${_baseBoxName}_shared';
  }

  List<InventoryItem> get items => _items;

  List<InventoryItem> get lowStockItems =>
      _items.where((item) => item.stockQuantity <= item.lowStockThreshold).toList();

  Future<void> loadItems() async {
    try {
      await loadInventoryFromHive();
      refreshInventoryList();
    } catch (e) {
      debugPrint('Error loading items: $e');
    }
  }

  // Coordinated initialization flow (Loosely Coupled)
  Future<void> initializeInventory(String uid) async {
    try {
      final remoteData = await loadInventoryFromFirebase(uid);
      if (remoteData.isNotEmpty) {
        await syncInventoryToHive(remoteData);
      }
      await loadInventoryFromHive();
      refreshInventoryList();
    } catch (e) {
      debugPrint('Error initializing inventory: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadInventoryFromFirebase(String uid) async {
    try {
      return await _firestoreService.fetchCollection(uid: uid, collection: _baseBoxName);
    } catch (e) {
      debugPrint('Error loading inventory from Firebase: $e');
      return [];
    }
  }

  Future<void> syncInventoryToHive(List<Map<String, dynamic>> remoteData) async {
    try {
      final box = await Hive.openBox(_scopedBoxName);
      for (var data in remoteData) {
        final item = SyncMapper.mapToInventoryItem(data);
        await box.put(item.id, item);
      }
    } catch (e) {
      debugPrint('Error syncing inventory to Hive: $e');
    }
  }

  Future<void> loadInventoryFromHive() async {
    try {
      final box = await Hive.openBox(_scopedBoxName);
      _items = box.values.cast<InventoryItem>().toList();
    } catch (e) {
      debugPrint('Error loading inventory from Hive: $e');
      rethrow;
    }
  }

  void refreshInventoryList() {
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      final box = await Hive.openBox(_scopedBoxName);
      await box.put(item.id, item);
      _items = box.values.cast<InventoryItem>().toList();
      notifyListeners();

      await _syncService.enqueueOperation(
        _baseBoxName,
        item.id,
        'CREATE',
        _itemToMap(item),
      );
    } catch (e) {
      debugPrint('Error adding item: $e');
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await item.save();
      notifyListeners();

      await _syncService.enqueueOperation(
        _baseBoxName,
        item.id,
        'UPDATE',
        _itemToMap(item),
      );
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> deleteItem(InventoryItem item) async {
    try {
      final itemId = item.id;
      await item.delete();
      _items.removeWhere((i) => i.id == itemId);
      notifyListeners();

      await _syncService.enqueueOperation(
        _baseBoxName,
        itemId,
        'DELETE',
        null,
      );
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  Future<void> adjustStock(String itemId, double adjustment) async {
    try {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index].stockQuantity += adjustment;
        _items[index].lastUpdated = DateTime.now();
        await _items[index].save();
        notifyListeners();

        await _syncService.enqueueOperation(
          _baseBoxName,
          itemId,
          'UPDATE',
          _itemToMap(_items[index]),
        );
      }
    } catch (e) {
      debugPrint('Error adjusting stock: $e');
    }
  }

  Map<String, dynamic> _itemToMap(InventoryItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'barcode': item.barcode,
      'purchasePrice': item.purchasePrice,
      'salePrice': item.salePrice,
      'stockQuantity': item.stockQuantity,
      'unit': item.unit,
      'lowStockThreshold': item.lowStockThreshold,
      'lastUpdated': item.lastUpdated.toIso8601String(),
    };
  }
}
