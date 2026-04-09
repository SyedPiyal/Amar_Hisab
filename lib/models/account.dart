import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type; // e.g., 'Assets', 'Liabilities', 'Equity', 'Income', 'Expenses'

  @HiveField(3)
  double balance;

  @HiveField(4)
  final String iconName;

  @HiveField(5)
  final String? parentId; // For hierarchy

  @HiveField(6)
  final String? code; // Accounting code (optional)

  Account({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    required this.iconName,
    this.parentId,
    this.code,
  });
}
