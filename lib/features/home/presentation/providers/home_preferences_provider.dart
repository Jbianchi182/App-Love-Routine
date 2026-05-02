import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';

class HomePreferencesNotifier extends AsyncNotifier<HomePreferences> {
  static const String boxName = 'home_preferences';
  static const String key = 'user_prefs';

  @override
  Future<HomePreferences> build() async {
    final box = Hive.box<HomePreferences>(boxName);
    final prefs = box.get(key);
    if (prefs == null) {
      final newPrefs = HomePreferences();
      await box.put(key, newPrefs);
      return newPrefs;
    }
    
    // Ensure all default sections are present
    final defaultSections = ['calendar', 'finance', 'upcoming'];
    bool changed = false;
    for (final section in defaultSections) {
      if (!prefs.sectionOrder.contains(section)) {
        prefs.sectionOrder.add(section);
        changed = true;
      }
    }
    if (changed) await prefs.save();
    
    return prefs;
  }

  Future<void> updateSectionOrder(List<String> order) async {
    final box = Hive.box<HomePreferences>(boxName);
    final prefs = state.value!;
    prefs.sectionOrder = order;
    await prefs.save();
    state = AsyncValue.data(prefs);
  }

  Future<void> updateUpcomingDays(int days) async {
    if (state.hasValue) {
      final prefs = state.value!;
      prefs.upcomingDaysRange = days;
      await prefs.save();
      state = AsyncData(prefs);
    }
  }

  Future<void> updatePinnedModules(List<String> modules) async {
    if (state.hasValue) {
      final prefs = state.value!;
      prefs.pinnedModules = modules;
      await prefs.save();
      state = AsyncData(prefs);
    }
  }

  Future<void> toggleMenuView() async {
    if (state.hasValue) {
      final prefs = state.value!;
      prefs.isGridView = !prefs.isGridView;
      await prefs.save();
      state = AsyncData(prefs);
    }
  }
}

final homePreferencesProvider =
    AsyncNotifierProvider<HomePreferencesNotifier, HomePreferences>(() {
      return HomePreferencesNotifier();
    });
