import 'package:hive/hive.dart';

part 'inventory_model.g.dart';

@HiveType(typeId: 0)
class InventoryItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  DateTime expirationDate;

  @HiveField(3)
  String category;

  @HiveField(4)
  int id;

  @HiveField(5)
  double price;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.expirationDate,
    required this.category,
    required this.id,
    required this.price,
  });
}