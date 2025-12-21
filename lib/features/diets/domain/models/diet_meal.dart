import 'package:hive/hive.dart';
import 'package:love_routine_app/features/diets/domain/enums/diet_tag.dart';

part 'diet_meal.g.dart';

@HiveType(typeId: 2)
class DietMeal extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name; // e.g. "Breakfast Plan A"

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> foodItems = [];

  @HiveField(4)
  List<DietTag> tags = [];

  // Caloric estimate per portion
  @HiveField(5)
  double? calories;
}
