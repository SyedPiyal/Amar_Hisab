import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_operation.dart';
import 'firestore_service.dart';
import 'connectivity_service.dart';
import 'sync_mapper.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _syncQueueBaseName = 'sync_queue';
  final FirestoreService _firestoreService = FirestoreService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  final _syncCompletedController = StreamController<void>.broadcast();
  Stream<void> get onSyncCompleted => _syncCompletedController.stream;
  
  // Notification for UID changes to help providers reload data
  final _uidController = StreamController<String?>.broadcast();
  Stream<String?> get onUidChanged => _uidController.stream;

  bool _isSyncing = false;
  String? _currentUid;
  StreamSubscription<bool>? _connectivitySubscription;

  String? get currentUid => _currentUid;

  String _getScopedBoxName(String baseName) {
    if (_currentUid == null) return '${baseName}_shared';
    return '${baseName}_$_currentUid';
  }

  Future<void> initialize(String uid) async {
    _currentUid = uid;
    _uidController.add(uid);
    
    // Ensure user-scoped sync queue box is open
    final scopedQueueName = _getScopedBoxName(_syncQueueBaseName);
    if (!Hive.isBoxOpen(scopedQueueName)) {
      await Hive.openBox<SyncOperation>(scopedQueueName);
    }

    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((hasConnection) {
      if (hasConnection) {
        syncPendingOperations();
      }
    });
    
    // Perform full sync
    performInitialSync();
  }

  void clearUid() {
    _currentUid = null;
    _uidController.add(null);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncCompletedController.close();
    _uidController.close();
  }

  Future<void> enqueueOperation(
      String collectionName, String recordId, String operationType, Map<String, dynamic>? data) async {
    try {
      if (_currentUid == null) {
        final prefs = await SharedPreferences.getInstance();
        _currentUid = prefs.getString('currentUserId');
      }
      
      if (_currentUid == null) return;

      final scopedQueueName = _getScopedBoxName(_syncQueueBaseName);
      final box = Hive.box<SyncOperation>(scopedQueueName);
      
      final operation = SyncOperation(
        id: const Uuid().v4(),
        collectionName: collectionName,
        recordId: recordId,
        operationType: operationType,
        data: data,
        timestamp: DateTime.now(),
      );

      await box.put(operation.id, operation);
      
      // Try to sync immediately
      syncPendingOperations();
    } catch (e) {
      debugPrint('Error enqueuing operation: $e');
    }
  }

  Future<void> syncPendingOperations() async {
    if (_currentUid == null) {
      final prefs = await SharedPreferences.getInstance();
      _currentUid = prefs.getString('currentUserId');
    }

    if (_isSyncing || _currentUid == null) return;

    final scopedQueueName = _getScopedBoxName(_syncQueueBaseName);
    final box = Hive.box<SyncOperation>(scopedQueueName);
    if (box.isEmpty) return;

    _isSyncing = true;

    try {
      final operations = box.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      for (var operation in operations) {
        bool success = false;
        try {
          if (operation.operationType == 'DELETE') {
            await _firestoreService.deleteRecord(
              uid: _currentUid!,
              collection: operation.collectionName,
              documentId: operation.recordId,
            );
          } else {
            // CREATE or UPDATE
            if (operation.data != null) {
              await _firestoreService.saveRecord(
                uid: _currentUid!,
                collection: operation.collectionName,
                documentId: operation.recordId,
                data: operation.data!,
              );
            }
          }
          success = true;
        } catch (e) {
          debugPrint('Failed to sync operation ${operation.id}: $e');
          if (e.toString().contains('network') || e.toString().contains('unavailable')) {
             break;
          }
          continue; 
        }

        if (success) {
          await box.delete(operation.id);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> performInitialSync() async {
    if (_currentUid == null) {
      final prefs = await SharedPreferences.getInstance();
      _currentUid = prefs.getString('currentUserId');
    }
    
    if (_currentUid == null) return;
    
    // First, push any local pending changes to cloud
    await syncPendingOperations();

    try {
      // List of collections to sync
      final collections = [
        'accounts',
        'transactions',
        'debts',
        'budgets',
        'scheduled_transactions',
        'savings_goals',
        'inventoryBox'
      ];

      for (var collection in collections) {
        final cloudData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: collection);
        if (cloudData.isNotEmpty) {
          final scopedBoxName = '${collection}_$_currentUid';
          final box = await Hive.openBox(scopedBoxName);
          for (var data in cloudData) {
            _mapAndSaveToHive(collection, data, box);
          }
        }
      }
      
      _syncCompletedController.add(null);
    } catch (e) {
      debugPrint('Failed to perform initial sync: $e');
    }
  }

  Future<void> _mapAndSaveToHive(String collection, Map<String, dynamic> data, Box box) async {
    try {
      dynamic model;
      switch (collection) {
        case 'accounts':
          model = SyncMapper.mapToAccount(data);
          break;
        case 'transactions':
          model = SyncMapper.mapToTransaction(data);
          break;
        case 'debts':
          model = SyncMapper.mapToDebt(data);
          break;
        case 'budgets':
          model = SyncMapper.mapToBudget(data);
          break;
        case 'scheduled_transactions':
          model = SyncMapper.mapToScheduledTransaction(data);
          break;
        case 'savings_goals':
          model = SyncMapper.mapToSavingsGoal(data);
          break;
        case 'inventoryBox':
          model = SyncMapper.mapToInventoryItem(data);
          break;
      }
      
      if (model != null) {
        await box.put(model.id, model);
      }
    } catch (e) {
      debugPrint('Error mapping/saving $collection: $e');
    }
  }
}
