import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/presentation/providers/finance_provider.dart';
import 'package:love_routine_app/features/finance/presentation/widgets/add_transaction_dialog.dart';
import 'package:love_routine_app/features/finance/presentation/widgets/financial_summary_widget.dart';
import 'package:intl/intl.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(financeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Finanças')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final income = ref
              .read(financeProvider.notifier)
              .calculateBalance(
                transactions
                    .where((t) => t.type == TransactionType.income)
                    .toList(),
              ); // Note: calculateBalance logic in provider might need adjustment to generic sum if used this way,
          // but checking provider again: calculates net balance.
          // We need separate income/expense sum.

          double totalIncome = 0;
          double totalExpense = 0;
          for (var t in transactions) {
            if (t.type == TransactionType.income) totalIncome += t.amount;
            if (t.type == TransactionType.expense) totalExpense += t.amount;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FinancialSummaryWidget(
                income: totalIncome,
                expense: totalExpense,
              ),
              const SizedBox(height: 24),
              Text('Transações Recentes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('Nenhuma transação registrada.')),
                )
              else
                ...transactions.map(
                  (t) => _buildTransactionItem(context, ref, t),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    FinanceTransaction transaction,
  ) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category.label} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R\$ ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref, transaction),
            ),
          ],
        ),
        onTap: () => _showAddDialog(context, ref, transaction: transaction),
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref, {
    FinanceTransaction? transaction,
  }) async {
    final result = await showDialog<FinanceTransaction>(
      context: context,
      builder: (_) => AddTransactionDialog(transaction: transaction),
    );

    if (result != null) {
      if (transaction == null) {
        ref.read(financeProvider.notifier).addTransaction(result);
      } else {
        // Update existing object fields
        transaction.title = result.title;
        transaction.amount = result.amount;
        transaction.type = result.type;
        transaction.category = result.category;
        transaction.date = result.date;
        ref.read(financeProvider.notifier).updateTransaction(transaction);
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FinanceTransaction transaction,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(financeProvider.notifier).deleteTransaction(transaction);
    }
  }
}
