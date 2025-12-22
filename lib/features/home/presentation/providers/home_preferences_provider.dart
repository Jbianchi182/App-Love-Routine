import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';

class HomePreferencesNotifier extends AsyncNotifier<HomePreferences> {
  static const String boxName = 'home_preferences';
  static const String key = 'user_prefs';

  @override
  Future<HomePreferences> build() async {
    final box = Hive.box<HomePreferences>(boxName);
    if (box.isEmpty) {
      // Initialize defaults
      final prefs = HomePreferences();
      await box.put(key, prefs);
      return prefs;
    }
    return box.get(key)!;
  }

  Future<void> updateSectionOrder(List<String> order) async {
    final box = Hive.box<HomePreferences>(boxName);
    final prefs = state.value!;
    prefs.sectionOrder = order;
    await prefs.save();
    state = AsyncValue.data(prefs);
  }

  Future<void> updateUpcomingDays(int days) async {
    final box = Hive.box<HomePreferences>(boxName);
    final prefs = state.value!;
    prefs.upcomingDaysRange = days;
    await prefs.save();
    state = AsyncValue.data(prefs);
  }
}

final homePreferencesProvider =
    AsyncNotifierProvider<HomePreferencesNotifier, HomePreferences>(() {
      return HomePreferencesNotifier();
    });
