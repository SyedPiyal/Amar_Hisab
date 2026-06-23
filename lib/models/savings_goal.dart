import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 7)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  int iconCodePoint;

  @HiveField(5)
  DateTime? targetDate;

  @HiveField(6)
  DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.iconCodePoint,
    this.targetDate,
    required this.createdAt,
  });
}
