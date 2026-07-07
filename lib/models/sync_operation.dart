import 'package:hive/hive.dart';

part 'sync_operation.g.dart';

@HiveType(typeId: 20) // Use a high typeId to avoid conflicts with existing models
class SyncOperation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String collectionName;

  @HiveField(2)
  final String recordId;

  @HiveField(3)
  final String operationType; // 'CREATE', 'UPDATE', 'DELETE'

  @HiveField(4)
  final Map<dynamic, dynamic>? data; // JSON representation of the model for CREATE/UPDATE

  @HiveField(5)
  final DateTime timestamp;

  SyncOperation({
    required this.id,
    required this.collectionName,
    required this.recordId,
    required this.operationType,
    this.data,
    required this.timestamp,
  });
}
