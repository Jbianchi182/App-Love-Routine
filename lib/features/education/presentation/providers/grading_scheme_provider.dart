import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/education/domain/models/grading_scheme.dart';

class GradingSchemeNotifier extends AsyncNotifier<List<GradingScheme>> {
  late Box<GradingScheme> _box;

  @override
  Future<List<GradingScheme>> build() async {
    _box = Hive.box<GradingScheme>('grading_schemes');
    return _box.values.toList();
  }

  Future<void> addScheme(GradingScheme scheme) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _box.add(scheme);
      return _box.values.toList();
    });
  }

  Future<void> deleteScheme(GradingScheme scheme) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await scheme.delete();
      return _box.values.toList();
    });
  }

  // Helper to get formula by ID
  String? getFormula(int? id) {
    if (id == null) return null;
    final scheme = _box.get(id);
    return scheme?.formula;
  }
}

final gradingSchemeProvider =
    AsyncNotifierProvider<GradingSchemeNotifier, List<GradingScheme>>(() {
      return GradingSchemeNotifier();
    });
