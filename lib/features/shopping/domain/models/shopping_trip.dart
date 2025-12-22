import 'package:hive/hive.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_item.dart';

part 'shopping_trip.g.dart';

@HiveType(typeId: 14)
class ShoppingTrip extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late double totalAmount;

  @HiveField(2)
  late List<ShoppingItem> items;

  @HiveField(3)
  String? paymentMethodId;

  ShoppingTrip({
    required this.date,
    required this.totalAmount,
    required this.items,
    this.paymentMethodId,
  });
}
