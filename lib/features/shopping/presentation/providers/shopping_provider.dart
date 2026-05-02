import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_item.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_trip.dart';
import 'package:love_routine_app/features/shopping/presentation/providers/shopping_list_provider.dart';
import 'package:love_routine_app/features/finance/presentation/providers/finance_provider.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_category.dart';

class ShoppingNotifier extends AsyncNotifier<List<ShoppingItem>> {
  static const String boxName = 'shopping_items';
  static const String historyBoxName = 'shopping_history';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ShoppingItem>> build() async {
    final box = Hive.box<ShoppingItem>(boxName);
    List<ShoppingItem> allItems = box.values.toList();
    final subscriptions = <StreamSubscription>[];
    
    // Fetch shared items for any shared lists the user has access to
    final listsAsync = ref.watch(shoppingListProvider);
    final sharedLists = listsAsync.asData?.value.where((l) => l.isShared && l.householdId != null).toList() ?? [];
    
    for (var list in sharedLists) {
      final sub = _firestore
          .collection('households')
          .doc(list.householdId)
          .collection('shopping_lists')
          .doc(list.id)
          .collection('items')
          .snapshots()
          .listen((snapshot) {
            final sharedItems = snapshot.docs.map((doc) {
              final data = doc.data();
              return ShoppingItem(
                name: data['name'] ?? '',
                quantity: (data['quantity'] ?? 1).toInt(),
                isBought: data['isBought'] ?? false,
                category: data['category'] ?? 'Geral',
                price: (data['price'] as num?)?.toDouble(),
              )..listId = list.id;
            }).toList();

            // SOURCE OF TRUTH: For shared lists, the items in Firestore are the truth.
            // We combine local-only items (from other lists) with these shared items.
            final currentAll = Hive.box<ShoppingItem>(boxName).values.toList();
            
            // Filter out any items currently in Hive that belong to THIS shared list
            // (we'll replace them with the fresh ones from Firestore)
            final otherItems = currentAll.where((i) => i.listId != list.id).toList();
            
            final merged = [...otherItems, ...sharedItems];
            state = AsyncValue.data(merged);
          });
      subscriptions.add(sub);
    }

    ref.onDispose(() {
      for (var sub in subscriptions) {
        sub.cancel();
      }
    });

    return allItems;
  }

  Future<void> addItem(ShoppingItem item, String listId) async {
    final box = Hive.box<ShoppingItem>(boxName);
    item.listId = listId;
    await box.add(item);
    
    // Sync to Cloud if list is shared
    final lists = ref.read(shoppingListProvider).asData?.value ?? [];
    final list = lists.firstWhere((l) => l.id == listId, orElse: () => lists.first);
    
    if (list.isShared && list.householdId != null) {
      await _firestore
          .collection('households')
          .doc(list.householdId)
          .collection('shopping_lists')
          .doc(listId)
          .collection('items')
          .doc(item.name) // Use name as ID for simplicity or generate UUID
          .set({
        'name': item.name,
        'quantity': item.quantity,
        'isBought': item.isBought,
        'category': item.category,
        'price': item.price,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    ref.invalidateSelf();
  }

  Future<void> toggleStatus(ShoppingItem item) async {
    item.isBought = !item.isBought;
    if (item.isInBox) await item.save();
    
    // Sync to Cloud if shared
    if (item.listId != null) {
      final lists = ref.read(shoppingListProvider).asData?.value ?? [];
      final list = lists.firstWhere((l) => l.id == item.listId, orElse: () => lists.first);
      
      if (list.isShared && list.householdId != null) {
        await _firestore
            .collection('households')
            .doc(list.householdId)
            .collection('shopping_lists')
            .doc(item.listId)
            .collection('items')
            .doc(item.name)
            .update({'isBought': item.isBought});
      }
    }
    
    ref.invalidateSelf();
  }

  Future<void> updateItem(ShoppingItem item) async {
    if (item.isInBox) await item.save();
    
    if (item.listId != null) {
      final lists = ref.read(shoppingListProvider).asData?.value ?? [];
      final list = lists.firstWhere((l) => l.id == item.listId, orElse: () => lists.first);
      
      if (list.isShared && list.householdId != null) {
        await _firestore
            .collection('households')
            .doc(list.householdId)
            .collection('shopping_lists')
            .doc(item.listId)
            .collection('items')
            .doc(item.name)
            .update({
          'quantity': item.quantity,
          'category': item.category,
        });
      }
    }
    ref.invalidateSelf();
  }

  Future<void> deleteItem(ShoppingItem item) async {
    final listId = item.listId;
    if (item.isInBox) await item.delete();
    
    if (listId != null) {
      final lists = ref.read(shoppingListProvider).asData?.value ?? [];
      final list = lists.firstWhere((l) => l.id == listId, orElse: () => lists.first);
      
      if (list.isShared && list.householdId != null) {
        await _firestore
            .collection('households')
            .doc(list.householdId)
            .collection('shopping_lists')
            .doc(listId)
            .collection('items')
            .doc(item.name)
            .delete();
      }
    }
    ref.invalidateSelf();
  }

  Future<void> updatePrice(ShoppingItem item, double price) async {
    item.price = price;
    if (item.isInBox) await item.save();
    
    if (item.listId != null) {
      final lists = ref.read(shoppingListProvider).asData?.value ?? [];
      final list = lists.firstWhere((l) => l.id == item.listId, orElse: () => lists.first);
      
      if (list.isShared && list.householdId != null) {
        await _firestore
            .collection('households')
            .doc(list.householdId)
            .collection('shopping_lists')
            .doc(item.listId)
            .collection('items')
            .doc(item.name)
            .update({'price': price});
      }
    }
    ref.invalidateSelf();
  }

  Future<void> finalizePurchase({
    required String marketName,
    required String paymentMethod,
    String? lastFourDigits,
  }) async {
    final box = Hive.box<ShoppingItem>(boxName);
    final historyBox = Hive.box<ShoppingTrip>(historyBoxName);

    final allItems = box.values.toList();
    final boughtItems = allItems.where((i) => i.isBought).toList();

    if (boughtItems.isEmpty) return;

    double total = 0;
    for (var item in boughtItems) {
      if (item.price != null) {
        total += item.price! * item.quantity;
      }
    }

    // Deep copy for history
    final historyItems = boughtItems
        .map(
          (e) => ShoppingItem(
            name: e.name,
            quantity: e.quantity,
            isBought: true,
            category: e.category,
            price: e.price,
          ),
        )
        .toList();

    final trip = ShoppingTrip(
      date: DateTime.now(),
      totalAmount: total,
      items: historyItems,
      marketName: marketName,
      paymentMethodId: paymentMethod,
      lastFourDigits: lastFourDigits,
    );

    await historyBox.add(trip);

    // Create Finance Transaction
    final transaction = FinanceTransaction()
      ..title = 'Compra: $marketName'
      ..amount = total
      ..date = DateTime.now()
      ..type = TransactionType.expense
      ..category = TransactionCategory.food
      ..paymentMethodId = paymentMethod + (lastFourDigits != null ? ' (**** $lastFourDigits)' : '');

    await ref.read(financeProvider.notifier).addTransaction(transaction);

    // Remove bought items from current list
    for (var item in boughtItems) {
      await item.delete();
    }

    state = AsyncValue.data(box.values.toList());
  }

  Future<void> deleteTrip(ShoppingTrip trip) async {
    await trip.delete();
  }
}

final shoppingProvider =
    AsyncNotifierProvider<ShoppingNotifier, List<ShoppingItem>>(() {
      return ShoppingNotifier();
    });

final shoppingHistoryProvider = StreamProvider<List<ShoppingTrip>>((ref) async* {
  final box = Hive.box<ShoppingTrip>(ShoppingNotifier.historyBoxName);
  
  // Yield initial value
  final initialList = box.values.toList();
  initialList.sort((a, b) => b.date.compareTo(a.date));
  yield initialList;

  // Listen for changes
  await for (final _ in box.watch()) {
    final list = box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    yield list;
  }
});
