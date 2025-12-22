import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 13)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  bool isBought;

  @HiveField(3)
  String? category; // e.g., "Alimentação", "Limpeza"

  @HiveField(4)
  double? price;

  ShoppingItem({
    required this.name,
    this.quantity = 1,
    this.isBought = false,
    this.category,
    this.price,
  });
}
