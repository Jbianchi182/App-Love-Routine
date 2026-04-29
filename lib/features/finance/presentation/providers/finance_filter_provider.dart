import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/presentation/providers/finance_provider.dart';

import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';

final financeFilterProvider = StateProvider<String>((ref) => 'Este mês');
final financeTypeFilterProvider = StateProvider<String>((ref) => 'Todas');

final availableFinanceFiltersProvider = Provider<List<String>>((ref) {
  final transactions = ref.watch(financeProvider).asData?.value ?? [];
  final Set<String> filters = {
    'Essa semana',
    'Semana passada',
    'Este mês',
    'Mês passado',
  };

  final now = DateTime.now();
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);

  for (var t in transactions) {
    if (t.date.isBefore(lastMonthStart)) {
      final monthYear = DateFormat('MM/yyyy').format(t.date);
      filters.add(monthYear);
    }
  }

  final list = filters.toList();
  final oldMonths = list.skip(4).toList();
  oldMonths.sort((a, b) {
    final dateA = DateFormat('MM/yyyy').parse(a);
    final dateB = DateFormat('MM/yyyy').parse(b);
    return dateB.compareTo(dateA);
  });

  return [
    'Essa semana',
    'Semana passada',
    'Este mês',
    'Mês passado',
    ...oldMonths,
  ];
});

final filteredTransactionsProvider = Provider<List<FinanceTransaction>>((ref) {
  final filter = ref.watch(financeFilterProvider);
  final transactions = ref.watch(financeProvider).asData?.value ?? [];
  
  final now = DateTime.now();
  
  final currentWeekday = now.weekday;
  final thisWeekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1));
  final thisWeekEnd = thisWeekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
  final lastWeekEnd = thisWeekStart.subtract(const Duration(seconds: 1));

  final thisMonthStart = DateTime(now.year, now.month, 1);
  final thisMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

  return transactions.where((t) {
    final typeFilter = ref.watch(financeTypeFilterProvider);
    if (typeFilter == 'Receitas' && t.type != TransactionType.income) return false;
    if (typeFilter == 'Despesas' && t.type != TransactionType.expense) return false;

    final date = t.date;
    switch (filter) {
      case 'Essa semana':
        return date.isAfter(thisWeekStart.subtract(const Duration(seconds: 1))) && 
               date.isBefore(thisWeekEnd.add(const Duration(seconds: 1)));
      case 'Semana passada':
        return date.isAfter(lastWeekStart.subtract(const Duration(seconds: 1))) && 
               date.isBefore(lastWeekEnd.add(const Duration(seconds: 1)));
      case 'Este mês':
        return date.isAfter(thisMonthStart.subtract(const Duration(seconds: 1))) && 
               date.isBefore(thisMonthEnd.add(const Duration(seconds: 1)));
      case 'Mês passado':
        return date.isAfter(lastMonthStart.subtract(const Duration(seconds: 1))) && 
               date.isBefore(lastMonthEnd.add(const Duration(seconds: 1)));
      default:
        try {
          final filterDate = DateFormat('MM/yyyy').parse(filter);
          return date.year == filterDate.year && date.month == filterDate.month;
        } catch (e) {
          return true;
        }
    }
  }).toList();
});
