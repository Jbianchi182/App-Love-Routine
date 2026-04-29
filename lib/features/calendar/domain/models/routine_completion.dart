import 'package:hive/hive.dart';

part 'routine_completion.g.dart';

@HiveType(typeId: 16)
class RoutineCompletion extends HiveObject {
  @HiveField(0)
  late DateTime date; // The day this completion refers to (ignoring time)

  @HiveField(1)
  late String routineId; // Using routine key as string or some unique identifier

  @HiveField(2)
  late String routineTitle;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  late DateTime scheduledTime;

  RoutineCompletion({
    required this.date,
    required this.routineId,
    required this.routineTitle,
    required this.isCompleted,
    required this.scheduledTime,
  });
}
