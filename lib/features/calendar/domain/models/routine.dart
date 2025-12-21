import 'package:hive/hive.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';

part 'routine.g.dart';

@HiveType(typeId: 0)
class Routine extends HiveObject {
  @HiveField(0)
  int? id; // Hive handles keys, but we can store ID explicitly if needed, or use key

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(5)
  late DateTime time;

  @HiveField(6)
  late RecurrenceType recurrence;

  @HiveField(7)
  List<int>? customDaysOfWeek;

  @HiveField(8)
  int? interval;

  @HiveField(9)
  RoutineStatus status = RoutineStatus.pending;

  @HiveField(10)
  List<RoutineHistoryEntry> history = [];
}

@HiveType(typeId: 1)
class RoutineHistoryEntry {
  @HiveField(0)
  late DateTime timestamp;

  @HiveField(1)
  late String details;

  @HiveField(2)
  RoutineStatus? previousStatus;

  @HiveField(3)
  RoutineStatus? newStatus;
}
