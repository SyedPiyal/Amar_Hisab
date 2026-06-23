import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 5)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double limitAmount;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  Budget({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
    required this.year,
  });
}
