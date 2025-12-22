import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_item.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_trip.dart';

class ShoppingNotifier extends AsyncNotifier<List<ShoppingItem>> {
  static const String boxName = 'shopping_items';
  static const String historyBoxName = 'shopping_history';

  @override
  Future<List<ShoppingItem>> build() async {
    final box = Hive.box<ShoppingItem>(boxName);
    return box.values.toList();
  }

  Future<void> addItem(ShoppingItem item) async {
    final box = Hive.box<ShoppingItem>(boxName);
    await box.add(item);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> updateItem(ShoppingItem item) async {
    await item.save();
    final box = Hive.box<ShoppingItem>(boxName);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> deleteItem(ShoppingItem item) async {
    await item.delete();
    final box = Hive.box<ShoppingItem>(boxName);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> toggleStatus(ShoppingItem item) async {
    item.isBought = !item.isBought;
    await item.save();
    final box = Hive.box<ShoppingItem>(boxName);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> updatePrice(ShoppingItem item, double price) async {
    item.price = price;
    await item.save();
    final box = Hive.box<ShoppingItem>(boxName);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> finalizePurchase() async {
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
    );

    await historyBox.add(trip);

    // Remove bought items from current list
    for (var item in boughtItems) {
      await item.delete();
    }

    state = AsyncValue.data(box.values.toList());
  }
}

final shoppingProvider =
    AsyncNotifierProvider<ShoppingNotifier, List<ShoppingItem>>(() {
      return ShoppingNotifier();
    });

final shoppingHistoryProvider = FutureProvider<List<ShoppingTrip>>((ref) async {
  final box = Hive.box<ShoppingTrip>(ShoppingNotifier.historyBoxName);
  final list = box.values.toList();
  list.sort((a, b) => b.date.compareTo(a.date));
  return list;
});
