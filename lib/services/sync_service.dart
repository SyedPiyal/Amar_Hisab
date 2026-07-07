import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_operation.dart';
import 'firestore_service.dart';
import 'connectivity_service.dart';
import 'sync_mapper.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _syncQueueBoxName = 'sync_queue';
  final FirestoreService _firestoreService = FirestoreService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  final _syncCompletedController = StreamController<void>.broadcast();
  Stream<void> get onSyncCompleted => _syncCompletedController.stream;
  
  bool _isSyncing = false;
  String? _currentUid;
  StreamSubscription<bool>? _connectivitySubscription;

  Future<void> initialize(String uid) async {
    _currentUid = uid;
    
    // Ensure box is open
    if (!Hive.isBoxOpen(_syncQueueBoxName)) {
      await Hive.openBox<SyncOperation>(_syncQueueBoxName);
    }

    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((hasConnection) {
      if (hasConnection) {
        syncPendingOperations();
      }
    });
    
    // Perform full sync if internet might be available initially
    performInitialSync();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncCompletedController.close();
  }

  Future<void> enqueueOperation(
      String collectionName, String recordId, String operationType, Map<String, dynamic>? data) async {
    final box = Hive.box<SyncOperation>(_syncQueueBoxName);
    
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
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing || _currentUid == null) return;

    final box = Hive.box<SyncOperation>(_syncQueueBoxName);
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
          // Break the loop on failure to ensure ordered execution and retry later
          break;
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
    if (_currentUid == null) return;
    
    // First, push any local pending changes to cloud
    await syncPendingOperations();

    try {
      // 1. Accounts
      final accountsData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: 'accounts');
      if (accountsData.isNotEmpty) {
        final box = await Hive.openBox('accounts');
        for (var data in accountsData) {
          final account = SyncMapper.mapToAccount(data);
          await box.put(account.id, account);
        }
      }

      // 2. Transactions
      final txData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: 'transactions');
      if (txData.isNotEmpty) {
        final box = await Hive.openBox('transactions');
        for (var data in txData) {
          final tx = SyncMapper.mapToTransaction(data);
          await box.put(tx.id, tx);
        }
      }

      // 3. Debts
      final debtsData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: 'debts');
      if (debtsData.isNotEmpty) {
        final box = await Hive.openBox('debts');
        for (var data in debtsData) {
          final debt = SyncMapper.mapToDebt(data);
          await box.put(debt.id, debt);
        }
      }

      // 4. Budgets
      final budgetsData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: 'budgets');
      if (budgetsData.isNotEmpty) {
        final box = await Hive.openBox('budgets');
        for (var data in budgetsData) {
          final budget = SyncMapper.mapToBudget(data);
          await box.put(budget.id, budget);
        }
      }

      // 5. Scheduled Transactions
      final schedulesData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: 'scheduled_transactions');
      if (schedulesData.isNotEmpty) {
        final box = await Hive.openBox('scheduled_transactions');
        for (var data in schedulesData) {
          final schedule = SyncMapper.mapToScheduledTransaction(data);
          await box.put(schedule.id, schedule);
        }
      }

      // 6. Savings Goals
      final goalsData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: 'savings_goals');
      if (goalsData.isNotEmpty) {
        final box = await Hive.openBox('savings_goals');
        for (var data in goalsData) {
          final goal = SyncMapper.mapToSavingsGoal(data);
          await box.put(goal.id, goal);
        }
      }

      // 7. Inventory Items
      final inventoryData = await _firestoreService.fetchCollection(uid: _currentUid!, collection: 'inventoryBox');
      if (inventoryData.isNotEmpty) {
        final box = await Hive.openBox('inventoryBox');
        for (var data in inventoryData) {
          final item = SyncMapper.mapToInventoryItem(data);
          await box.put(item.id, item);
        }
      }
      
      _syncCompletedController.add(null);
    } catch (e) {
      debugPrint('Failed to perform initial sync: $e');
    }
  }
}
