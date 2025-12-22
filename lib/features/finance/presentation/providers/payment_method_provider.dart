import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/finance/domain/models/payment_method.dart';

class PaymentMethodNotifier extends AsyncNotifier<List<PaymentMethod>> {
  static const String boxName = 'payment_methods';

  @override
  Future<List<PaymentMethod>> build() async {
    final box = Hive.box<PaymentMethod>(boxName);
    return box.values.toList();
  }

  Future<void> addMethod(PaymentMethod method) async {
    final box = Hive.box<PaymentMethod>(boxName);
    await box.add(method);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> updateMethod(PaymentMethod method) async {
    await method.save();
    final box = Hive.box<PaymentMethod>(boxName);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> deleteMethod(PaymentMethod method) async {
    await method.delete();
    final box = Hive.box<PaymentMethod>(boxName);
    state = AsyncValue.data(box.values.toList());
  }
}

final paymentMethodProvider =
    AsyncNotifierProvider<PaymentMethodNotifier, List<PaymentMethod>>(() {
      return PaymentMethodNotifier();
    });
