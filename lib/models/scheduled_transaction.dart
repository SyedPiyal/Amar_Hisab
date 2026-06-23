import 'package:hive/hive.dart';

part 'scheduled_transaction.g.dart';

@HiveType(typeId: 6)
class ScheduledTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String accountId;

  @HiveField(4)
  final String type; // 'Income' or 'Expense'

  @HiveField(5)
  final String category;

  @HiveField(6)
  final String frequency; // 'Daily', 'Weekly', 'Monthly'

  @HiveField(7)
  DateTime nextDueDate;

  @HiveField(8)
  bool isActive;

  ScheduledTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.accountId,
    required this.type,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
    this.isActive = true,
  });
}
