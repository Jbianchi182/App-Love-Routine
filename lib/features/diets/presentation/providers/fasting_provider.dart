import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/diets/domain/models/fasting_routine.dart';

class FastingNotifier extends AsyncNotifier<List<FastingRoutine>> {
  late Box<FastingRoutine> _box;

  @override
  Future<List<FastingRoutine>> build() async {
    _box = Hive.box<FastingRoutine>('fasting_routines');
    return _fetchAll();
  }

  Future<List<FastingRoutine>> _fetchAll() async {
    return _box.values.toList();
  }

  Future<void> addFastingRoutine(FastingRoutine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Ensure only one active routine if needed, or allow multiple
      // Based on plan: "permite apenas 1 rotina de jejum ativa por vez"
      // We can disable others if this one is active.
      if (routine.isActive) {
        for (var r in _box.values) {
          if (r.isActive) {
            r.isActive = false;
            await r.save();
          }
        }
      }
      await _box.add(routine);
      return _fetchAll();
    });
  }

  Future<void> updateFastingRoutine(FastingRoutine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (routine.isActive) {
        for (var r in _box.values) {
          if (r.isActive && r.key != routine.key) {
            r.isActive = false;
            await r.save();
          }
        }
      }
      await routine.save();
      return _fetchAll();
    });
  }

  Future<void> deleteFastingRoutine(FastingRoutine routine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await routine.delete();
      return _fetchAll();
    });
  }
}

final fastingProvider =
    AsyncNotifierProvider<FastingNotifier, List<FastingRoutine>>(() {
  return FastingNotifier();
});
