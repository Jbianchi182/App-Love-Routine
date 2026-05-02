import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_list_model.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_item.dart';
import 'package:love_routine_app/features/household/presentation/providers/household_provider.dart';
import 'package:uuid/uuid.dart';

class ShoppingListNotifier extends AsyncNotifier<List<ShoppingList>> {
  static const String boxName = 'shopping_lists';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ShoppingList>> build() async {
    final box = Hive.box<ShoppingList>(boxName);
    
    // 1. Initial local lists
    List<ShoppingList> allLists = box.values.toList();
    
    // 2. Watch household changes
    final householdAsync = ref.watch(householdProvider);
    final household = householdAsync.asData?.value;
    
    if (household != null && household.sharedModules.contains('shopping')) {
      // 3. Listen to Shared Lists Stream
      final sharedStream = _firestore
          .collection('households')
          .doc(household.id)
          .collection('shopping_lists')
          .snapshots();

      final subscription = sharedStream.listen((snapshot) {
        final sharedLists = snapshot.docs.map((doc) {
          final data = doc.data();
          return ShoppingList(
            id: doc.id,
            name: data['name'],
            icon: data['icon'],
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isShared: true,
            householdId: household.id,
          );
        }).toList();

        // Refresh allLists from Hive again to merge
        final currentLocal = Hive.box<ShoppingList>(boxName).values.toList();
        final localIds = currentLocal.map((l) => l.id).toSet();
        
        final merged = [...currentLocal];
        for (var shared in sharedLists) {
          if (!localIds.contains(shared.id)) {
            merged.add(shared);
          }
        }
        merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        state = AsyncValue.data(merged);
      });

      ref.onDispose(() => subscription.cancel());
    }

    return allLists..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> addList(String name, String icon, {bool isShared = false, String? householdId}) async {
    final box = Hive.box<ShoppingList>(boxName);
    final id = const Uuid().v4();
    final newList = ShoppingList(
      id: id,
      name: name,
      icon: icon,
      createdAt: DateTime.now(),
      isShared: isShared,
      householdId: householdId,
    );
    
    await box.put(newList.id, newList);
    
    if (isShared && householdId != null) {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('shopping_lists')
          .doc(id)
          .set({
        'name': name,
        'icon': icon,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    
    ref.invalidateSelf();
  }

  Future<void> updateList(String id, {String? name, bool? isShared, String? householdId}) async {
    final box = Hive.box<ShoppingList>(boxName);
    final list = box.get(id);
    if (list == null) return;

    final updatedList = ShoppingList(
      id: list.id,
      name: name ?? list.name,
      icon: list.icon,
      createdAt: list.createdAt,
      isShared: isShared ?? list.isShared,
      householdId: isShared == true ? (householdId ?? list.householdId) : null,
    );

    // Update Local
    await box.put(id, updatedList);

    // Update Cloud
    if (updatedList.isShared && updatedList.householdId != null) {
      await _firestore
          .collection('households')
          .doc(updatedList.householdId)
          .collection('shopping_lists')
          .doc(id)
          .set({
        'name': updatedList.name,
        'icon': updatedList.icon,
        'createdAt': updatedList.createdAt,
      });

      // BULK SYNC: Upload existing items to cloud if list just became shared
      final itemsBox = Hive.box<ShoppingItem>('shopping_items');
      final localItems = itemsBox.values.where((i) => i.listId == id).toList();
      for (var item in localItems) {
        await _firestore
            .collection('households')
            .doc(updatedList.householdId)
            .collection('shopping_lists')
            .doc(id)
            .collection('items')
            .doc(item.name)
            .set({
          'name': item.name,
          'quantity': item.quantity,
          'isBought': item.isBought,
          'category': item.category,
          'price': item.price,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } else if (list.isShared && !updatedList.isShared && list.householdId != null) {
      // Was shared, now private -> remove from cloud
      await _firestore
          .collection('households')
          .doc(list.householdId)
          .collection('shopping_lists')
          .doc(id)
          .delete();
    }

    ref.invalidateSelf();
  }

  Future<void> deleteList(String id) async {
    final box = Hive.box<ShoppingList>(boxName);
    final list = box.get(id);
    
    if (list != null && list.isShared && list.householdId != null) {
      await _firestore
          .collection('households')
          .doc(list.householdId)
          .collection('shopping_lists')
          .doc(id)
          .delete();
    }
    
    await box.delete(id);
    ref.invalidateSelf();
  }
}

final shoppingListProvider = AsyncNotifierProvider<ShoppingListNotifier, List<ShoppingList>>(() {
  return ShoppingListNotifier();
});

final selectedListIdProvider = StateProvider<String>((ref) => 'default');
