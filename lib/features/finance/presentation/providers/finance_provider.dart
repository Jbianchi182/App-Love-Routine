import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';

class FinanceNotifier extends AsyncNotifier<List<FinanceTransaction>> {
  late Box<FinanceTransaction> _box;

  @override
  Future<List<FinanceTransaction>> build() async {
    _box = Hive.box<FinanceTransaction>('transactions');
    return _fetchTransactions();
  }

  Future<List<FinanceTransaction>> _fetchTransactions() async {
    final transactions = _box.values.toList();
    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _box.add(transaction);
      // Ensure ID is set if needed, though Hive Object handles key.
      transaction.id = transaction.key as int;
      await transaction.save(); // Save ID back if we really used it

      return _fetchTransactions();
    });
  }

  Future<void> updateTransaction(FinanceTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await transaction.save();
      return _fetchTransactions();
    });
  }

  Future<void> deleteTransaction(FinanceTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await transaction.delete();
      return _fetchTransactions();
    });
  }

  double calculateBalance(List<FinanceTransaction> transactions) {
    double total = 0;
    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        total += t.amount;
      } else {
        total -= t.amount;
      }
    }
    return total;
  }
}

final financeProvider =
    AsyncNotifierProvider<FinanceNotifier, List<FinanceTransaction>>(() {
      return FinanceNotifier();
    });
