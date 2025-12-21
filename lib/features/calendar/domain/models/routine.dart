import 'package:isar/isar.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';

part 'routine.g.dart';

@collection
class Routine {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;

  late DateTime startDate;
  DateTime? endDate;
  
  // Time of day stored as DateTime (using arbitrary date) or just minutes from midnight could work, 
  // but DateTime is easier for Isar basic support. 
  // We'll trust the UI to handle the time component.
  late DateTime time; 

  @Enumerated(EnumType.name)
  late RecurrenceType recurrence;

  // For custom recurrence (e.g., "every 2nd Monday") - complex, simplified for now
  // Storing specific days of week [1, 3, 5] for Mon, Wed, Fri
  List<int>? customDaysOfWeek; 
  
  // For "every X days/weeks/months"
  int? interval;

  @Enumerated(EnumType.name)
  RoutineStatus status = RoutineStatus.pending;

  // History of changes or completion
  // Ideally this might be a separate collection if it grows large, 
  // but embedding for simplicity for now.
  List<RoutineHistoryEntry> history = [];
}

@embedded
class RoutineHistoryEntry {
  late DateTime timestamp;
  late String details; // e.g. "Status changed to Completed"
  
  @Enumerated(EnumType.name)
  RoutineStatus? previousStatus;
  
  @Enumerated(EnumType.name)
  RoutineStatus? newStatus;
}
