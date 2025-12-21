import 'package:isar/isar.dart';
import 'package:love_routine_app/features/diets/domain/enums/diet_tag.dart';

part 'diet_meal.g.dart';

@collection
class DietMeal {
  Id id = Isar.autoIncrement;

  late String name; // e.g. "Breakfast Plan A"
  String? description;

  List<String> foodItems = [];

  @Enumerated(EnumType.name)
  List<DietTag> tags = [];

  // Caloric estimate per portion
  double? calories;
}
