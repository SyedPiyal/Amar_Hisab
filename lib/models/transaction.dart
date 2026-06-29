import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String accountId;

  @HiveField(5)
  final String type; // 'Income', 'Expense', 'Transfer'

  @HiveField(6)
  final String category;

  @HiveField(7)
  final String? creditAccountId;

  @HiveField(8)
  final String? debitAccountId;

  @HiveField(9)
  final bool isSplit;

  @HiveField(10)
  final Map<String, double>? splitDetails; // Category name -> Amount

  @HiveField(11)
  final String? debtId;

  @HiveField(12)
  final List<String>? attachmentPaths;

  @HiveField(13)
  final double? taxPercentage;

  @HiveField(14)
  final double? taxAmount;

  @HiveField(15)
  final String? inventoryItemId;

  @HiveField(16)
  final double? inventoryQuantity;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.accountId,
    required this.type,
    required this.category,
    this.creditAccountId,
    this.debitAccountId,
    this.isSplit = false,
    this.splitDetails,
    this.debtId,
    this.attachmentPaths,
    this.taxPercentage,
    this.taxAmount,
    this.inventoryItemId,
    this.inventoryQuantity,
  });
}
