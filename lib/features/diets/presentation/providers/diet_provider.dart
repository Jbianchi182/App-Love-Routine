import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:love_routine_app/features/diets/domain/models/diet_meal.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';

class DietNotifier extends AsyncNotifier<List<DietMeal>> {
  late Isar _isar;

  @override
  Future<List<DietMeal>> build() async {
    _isar = await ref.watch(isarProvider.future);
    return _fetchAllDiets();
  }

  Future<List<DietMeal>> _fetchAllDiets() async {
    return _isar.dietMeals.where().findAll();
  }

  Future<void> addDietMeal(DietMeal meal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _isar.writeTxn(() async {
        await _isar.dietMeals.put(meal);
      });
      return _fetchAllDiets();
    });
  }

  Future<void> updateDietMeal(DietMeal meal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _isar.writeTxn(() async {
        await _isar.dietMeals.put(meal);
      });
      return _fetchAllDiets();
    });
  }

  Future<void> deleteDietMeal(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _isar.writeTxn(() async {
        await _isar.dietMeals.delete(id);
      });
      return _fetchAllDiets();
    });
  }
}

final dietProvider = AsyncNotifierProvider<DietNotifier, List<DietMeal>>(() {
  return DietNotifier();
});
