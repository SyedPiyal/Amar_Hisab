import 'package:hive/hive.dart';

part 'debt.g.dart';

@HiveType(typeId: 4)
class Debt extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  double remainingAmount;

  @HiveField(4)
  final String type; // 'Receivable' (পাওনা) or 'Payable' (দেনা)

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final DateTime? dueDate;

  @HiveField(7)
  final String? note;

  @HiveField(8)
  final String? accountId;

  @HiveField(9)
  String status; // 'Active', 'Settled'

  @HiveField(10)
  final String? phoneNumber;

  Debt({
    required this.id,
    required this.personName,
    required this.amount,
    required this.remainingAmount,
    required this.type,
    required this.date,
    this.dueDate,
    this.note,
    this.accountId,
    this.status = 'Active',
    this.phoneNumber,
  });
}
