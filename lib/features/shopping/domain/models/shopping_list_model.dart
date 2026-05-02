import 'package:hive/hive.dart';

part 'shopping_list_model.g.dart';

@HiveType(typeId: 30)
class ShoppingList extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon; // Icon name from a predefined list

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4, defaultValue: false)
  bool isShared = false;

  @HiveField(5)
  String? householdId;

  ShoppingList({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    this.isShared = false,
    this.householdId,
  });
}
