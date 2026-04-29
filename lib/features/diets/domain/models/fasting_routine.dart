import 'package:hive/hive.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';

part 'fasting_routine.g.dart';

@HiveType(typeId: 23)
class FastingRoutine extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name; // ex: "Jejum 16:8"

  @HiveField(2)
  late int fastingHours;

  @HiveField(3)
  late DateTime startTime;

  @HiveField(4)
  late bool isActive;

  @HiveField(5)
  late RecurrenceType recurrence = RecurrenceType.daily;

  @HiveField(6)
  List<int>? customDaysOfWeek;

  @HiveField(7)
  List<int>? customDaysOfMonth;

  @HiveField(8)
  late DateTime startDate = DateTime.now();
}
