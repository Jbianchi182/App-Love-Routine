import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';
import 'package:path_provider/path_provider.dart';

// Persistent Isar instance provider
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [RoutineSchema],
    directory: dir.path,
  );
});

class RoutineNotifier extends AsyncNotifier<List<Routine>> {
  late Isar _isar;

  @override
  Future<List<Routine>> build() async {
    _isar = await ref.watch(isarProvider.future);
    return _fetchAllRoutines();
  }

  Future<List<Routine>> _fetchAllRoutines() async {
    return _isar.routines.where().findAll();
  }

  Future<void> addRoutine(Routine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _isar.writeTxn(() async {
        await _isar.routines.put(routine);
      });
      return _fetchAllRoutines();
    });
  }

  Future<void> updateRoutine(Routine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _isar.writeTxn(() async {
        await _isar.routines.put(routine);
      });
      return _fetchAllRoutines();
    });
  }

  Future<void> deleteRoutine(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _isar.writeTxn(() async {
        await _isar.routines.delete(id);
      });
      return _fetchAllRoutines();
    });
  }
  
  Future<void> updateStatus(int id, RoutineStatus status) async {
     state = const AsyncValue.loading();
     state = await AsyncValue.guard(() async {
       await _isar.writeTxn(() async {
         final routine = await _isar.routines.get(id);
         if (routine != null) {
           routine.status = status;
           // Add history entry
           routine.history = [
             ...routine.history,
             RoutineHistoryEntry()
               ..timestamp = DateTime.now()
               ..details = "Status update to ${status.label}"
               ..newStatus = status
           ];
           await _isar.routines.put(routine);
         }
       });
       return _fetchAllRoutines();
     });
  }
}

final routineProvider = AsyncNotifierProvider<RoutineNotifier, List<Routine>>(() {
  return RoutineNotifier();
});
