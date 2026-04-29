import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine_completion.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/calendar_logic_provider.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';

class RoutineHistoryNotifier extends AsyncNotifier<List<RoutineCompletion>> {
  static const String boxName = 'routine_completions';
  static const String metaBoxName = 'routine_history_meta';
  static const String lastProcessedKey = 'last_processed_date';

  @override
  Future<List<RoutineCompletion>> build() async {
    final box = Hive.box<RoutineCompletion>(boxName);
    
    // Check for missed days and log them
    await _processMissedDays();
    
    final list = box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> _processMissedDays() async {
    final metaBox = await Hive.openBox(metaBoxName);
    final lastProcessedStr = metaBox.get(lastProcessedKey) as String?;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime lastDate;
    if (lastProcessedStr == null) {
      // First time, start from yesterday
      lastDate = today.subtract(const Duration(days: 1));
    } else {
      lastDate = DateTime.parse(lastProcessedStr);
    }

    // If already processed today or later, skip
    if (lastDate.isAtSameMomentAs(today) || lastDate.isAfter(today)) return;

    // Process each day from lastDate + 1 to yesterday
    final box = Hive.box<RoutineCompletion>(boxName);
    final routineBox = Hive.box<Routine>('routines');
    final logic = ref.read(calendarLogicProvider);

    DateTime processDate = lastDate.add(const Duration(days: 1));
    while (processDate.isBefore(today)) {
      // For each routine that should have happened on processDate
      final events = logic.getEventsForDay(processDate);
      for (var event in events) {
        if (event.originalObject is Routine) {
          final routine = event.originalObject as Routine;
          
          // Check if it's already logged (to avoid duplicates)
          final alreadyLogged = box.values.any((c) => 
            c.date.isAtSameMomentAs(processDate) && c.routineId == routine.key.toString());
          
          if (!alreadyLogged) {
            // Logic: if status is currently completed, but we are processing a past day...
            // Actually, we should probably check if the routine HAS history for that day.
            // For now, let's assume if it's not marked as completed today, it wasn't.
            // But wait, the user marks it "Today". 
            // If they didn't mark it, it's false.
            
            final completion = RoutineCompletion(
              date: processDate,
              routineId: routine.key.toString(),
              routineTitle: routine.title,
              isCompleted: false, // In a missed day, it's always false unless we track per-day status
              scheduledTime: event.time,
            );
            await box.add(completion);
          }
        }
      }
      processDate = processDate.add(const Duration(days: 1));
    }

    await metaBox.put(lastProcessedKey, today.toIso8601String());
  }

  Future<void> logTodayCompletion(Routine routine, bool isCompleted) async {
    final box = Hive.box<RoutineCompletion>(boxName);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Update or Add
    final existingIndex = box.values.toList().indexWhere((c) => 
      c.date.isAtSameMomentAs(today) && c.routineId == routine.key.toString());

    if (existingIndex != -1) {
      final completion = box.getAt(existingIndex)!;
      completion.isCompleted = isCompleted;
      await completion.save();
    } else {
      final completion = RoutineCompletion(
        date: today,
        routineId: routine.key.toString(),
        routineTitle: routine.title,
        isCompleted: isCompleted,
        scheduledTime: routine.time,
      );
      await box.add(completion);
    }
    
    state = AsyncValue.data(box.values.toList()..sort((a, b) => b.date.compareTo(a.date)));
  }
}

final routineHistoryProvider = AsyncNotifierProvider<RoutineHistoryNotifier, List<RoutineCompletion>>(() {
  return RoutineHistoryNotifier();
});
