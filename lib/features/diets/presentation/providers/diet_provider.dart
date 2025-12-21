import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/diets/domain/models/diet_meal.dart';

class DietNotifier extends AsyncNotifier<List<DietMeal>> {
  late Box<DietMeal> _box;

  @override
  Future<List<DietMeal>> build() async {
    _box = Hive.box<DietMeal>('diet_meals');
    return _fetchAllDiets();
  }

  Future<List<DietMeal>> _fetchAllDiets() async {
    return _box.values.toList();
  }

  Future<void> addDietMeal(DietMeal meal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _box.add(meal);
      return _fetchAllDiets();
    });
  }

  Future<void> updateDietMeal(DietMeal meal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await meal.save();
      return _fetchAllDiets();
    });
  }

  Future<void> deleteDietMeal(DietMeal meal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await meal.delete();
      return _fetchAllDiets();
    });
  }
}

final dietProvider = AsyncNotifierProvider<DietNotifier, List<DietMeal>>(() {
  return DietNotifier();
});
