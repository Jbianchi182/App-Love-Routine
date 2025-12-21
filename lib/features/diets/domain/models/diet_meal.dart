import 'package:hive/hive.dart';
import 'package:love_routine_app/features/diets/domain/enums/diet_tag.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';

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

  @HiveField(6)
  late RecurrenceType recurrence = RecurrenceType.daily;

  @HiveField(7)
  List<int>? customDaysOfWeek;

  @HiveField(8)
  late DateTime startDate = DateTime.now();

  @HiveField(9)
  DateTime? endDate;

  @HiveField(10)
  late DateTime time = DateTime.now();

  @HiveField(11)
  List<int>? customDaysOfMonth;
}
