import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 11)
class Product extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String barcode;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.stock = 0,
  });

  @override
  List<Object?> get props => [id, name, barcode, price, stock];
}
