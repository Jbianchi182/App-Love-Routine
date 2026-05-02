import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:love_routine_app/features/household/data/repositories/household_repository.dart';
import 'package:love_routine_app/features/household/domain/models/household.dart';

class HouseholdNotifier extends AsyncNotifier<Household?> {
  final HouseholdRepository _repository = HouseholdRepository();

  @override
  Future<Household?> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return null;
    return _repository.getHouseholdForUser(user.uid);
  }

  Future<void> createHousehold(String name) async {
    final user = ref.read(authProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createHousehold(name, user.uid, user.email ?? '');
      return _repository.getHouseholdForUser(user.uid);
    });
  }

  Future<void> addMember(String email) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addMemberByEmail(current.id, email);
      return _repository.getHouseholdForUser(ref.read(authProvider)!.uid);
    });
  }

  Future<void> removeMember(String uid, String email) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.removeMember(current.id, uid, email);
      return _repository.getHouseholdForUser(ref.read(authProvider)!.uid);
    });
  }

  Future<void> toggleModule(String moduleSlug) async {
    final current = state.value;
    if (current == null) return;

    final List<String> newModules = List<String>.from(current.sharedModules);
    if (newModules.contains(moduleSlug)) {
      newModules.remove(moduleSlug);
    } else {
      newModules.add(moduleSlug);
    }

    final updated = current.copyWith(sharedModules: newModules);
    
    // Optimistic update to UI
    state = AsyncValue.data(updated);

    try {
      await _repository.updateHousehold(updated);
    } catch (e, st) {
      // Rollback if failed
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateName(String name) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(name: name);
    state = AsyncValue.data(updated);

    try {
      await _repository.updateHousehold(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final householdProvider = AsyncNotifierProvider<HouseholdNotifier, Household?>(() {
  return HouseholdNotifier();
});
