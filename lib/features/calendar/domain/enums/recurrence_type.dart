import 'package:hive/hive.dart';

part 'recurrence_type.g.dart';

@HiveType(typeId: 8)
enum RecurrenceType {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  custom,
}
