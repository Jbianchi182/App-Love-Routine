import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/finance/domain/models/payment_card.dart';

class CardNotifier extends AsyncNotifier<List<PaymentCard>> {
  static const String boxName = 'payment_cards';

  @override
  Future<List<PaymentCard>> build() async {
    final box = await Hive.openBox<PaymentCard>(boxName);
    return box.values.toList();
  }

  Future<void> addCard(PaymentCard card) async {
    final box = Hive.box<PaymentCard>(boxName);
    await box.add(card);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> deleteCard(PaymentCard card) async {
    await card.delete();
    final box = Hive.box<PaymentCard>(boxName);
    state = AsyncValue.data(box.values.toList());
  }
}

final cardProvider = AsyncNotifierProvider<CardNotifier, List<PaymentCard>>(() {
  return CardNotifier();
});
