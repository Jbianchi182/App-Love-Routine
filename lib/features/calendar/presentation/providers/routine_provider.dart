import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';

class RoutineNotifier extends AsyncNotifier<List<Routine>> {
  late Box<Routine> _box;

  @override
  Future<List<Routine>> build() async {
    _box = Hive.box<Routine>('routines');
    return _fetchAllRoutines();
  }

  Future<List<Routine>> _fetchAllRoutines() async {
    return _box.values.toList();
  }

  Future<void> addRoutine(Routine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _box.add(routine);
      return _fetchAllRoutines();
    });
  }

  Future<void> updateRoutine(Routine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await routine.save(); // HiveObject method
      return _fetchAllRoutines();
    });
  }

  Future<void> deleteRoutine(Routine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await routine.delete(); // HiveObject method
      return _fetchAllRoutines();
    });
  }

  Future<void> updateStatus(dynamic key, RoutineStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final routine = _box.get(key);
      if (routine != null) {
        routine.status = status;
        // Add history entry
        routine.history = [
          ...routine.history,
          RoutineHistoryEntry()
            ..timestamp = DateTime.now()
            ..details = "Status update to ${status.label}"
            ..newStatus = status,
        ];
        await routine.save();
      }
      return _fetchAllRoutines();
    });
  }
}

final routineProvider = AsyncNotifierProvider<RoutineNotifier, List<Routine>>(
  () {
    return RoutineNotifier();
  },
);
