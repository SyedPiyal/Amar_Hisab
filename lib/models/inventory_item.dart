import 'package:hive/hive.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 10)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? barcode;

  @HiveField(3)
  double purchasePrice;

  @HiveField(4)
  double salePrice;

  @HiveField(5)
  double stockQuantity;

  @HiveField(6)
  String unit; // e.g., 'Piece', 'KG', 'Litre'

  @HiveField(7)
  double lowStockThreshold;

  @HiveField(8)
  DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.name,
    this.barcode,
    required this.purchasePrice,
    required this.salePrice,
    required this.stockQuantity,
    this.unit = 'Piece',
    this.lowStockThreshold = 5.0,
    required this.lastUpdated,
  });
}
