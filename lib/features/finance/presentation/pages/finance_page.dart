import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/presentation/providers/finance_provider.dart';
import 'package:love_routine_app/features/finance/presentation/widgets/add_transaction_dialog.dart';
import 'package:love_routine_app/features/finance/presentation/widgets/financial_summary_widget.dart';
import 'package:love_routine_app/features/finance/presentation/providers/finance_filter_provider.dart';
import 'package:intl/intl.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';
import 'package:love_routine_app/features/finance/presentation/providers/card_provider.dart';
import 'package:love_routine_app/features/finance/domain/models/payment_card.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(financeProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final availableFilters = ref.watch(availableFinanceFiltersProvider);
    final currentFilter = ref.watch(financeFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finanças',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'cards_btn',
            onPressed: () => _showCardsDialog(context, ref),
            icon: const Icon(Icons.credit_card),
            label: const Text('Meus Cartões', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'transaction_btn',
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Nova Transação', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: transactionsAsync.when(
          data: (_) {
            double totalIncome = 0;
            double totalExpense = 0;
            for (var t in filteredTransactions) {
              if (t.type == TransactionType.income) totalIncome += t.amount;
              if (t.type == TransactionType.expense) totalExpense += t.amount;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = availableFilters[index];
                    final isSelected = filter == currentFilter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(financeFilterProvider.notifier).state = filter;
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Todas', label: Text('Todas')),
                  ButtonSegment(value: 'Receitas', label: Text('Receitas')),
                  ButtonSegment(value: 'Despesas', label: Text('Despesas')),
                ],
                selected: {ref.watch(financeTypeFilterProvider)},
                onSelectionChanged: (set) {
                  ref.read(financeTypeFilterProvider.notifier).state = set.first;
                },
              ),
              const SizedBox(height: 16),
              FinancialSummaryWidget(
                income: totalIncome,
                expense: totalExpense,
              ),
              const SizedBox(height: 24),
              Text('Transações Recentes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (filteredTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('Nenhuma transação registrada.')),
                )
              else
                ...filteredTransactions.map(
                  (t) => _buildTransactionItem(context, ref, t),
                ),
            ],
          );
        },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erro: $err')),
        ),
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

  Future<void> _showCardsDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final cardsAsync = ref.watch(cardProvider);
            return AlertDialog(
              title: const Text('Meus Cartões'),
              content: SizedBox(
                width: double.maxFinite,
                child: cardsAsync.when(
                  data: (cards) {
                    if (cards.isEmpty) {
                      return const Text('Nenhum cartão cadastrado.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return ListTile(
                          leading: Icon(
                            card.isCredit ? Icons.credit_score : Icons.payment,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(card.displayName),
                          subtitle: Text(card.typeLabel),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => ref.read(cardProvider.notifier).deleteCard(card),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erro: $e'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
                FilledButton(
                  onPressed: () => _showAddCardDialog(context, ref),
                  child: const Text('Adicionar Novo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddCardDialog(BuildContext context, WidgetRef ref) async {
    final digitsController = TextEditingController();
    String brand = 'Visa';
    bool isCredit = true;
    final nicknameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Novo Cartão'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: digitsController,
                  decoration: const InputDecoration(
                    labelText: 'Últimos 4 dígitos',
                    hintText: 'Ex: 1234',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: brand,
                  decoration: const InputDecoration(labelText: 'Bandeira'),
                  items: ['Visa', 'Mastercard', 'Elo', 'Amex', 'Outra']
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => brand = val);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Tipo:'),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Crédito'),
                      selected: isCredit,
                      onSelected: (val) => setState(() => isCredit = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Débito'),
                      selected: !isCredit,
                      onSelected: (val) => setState(() => isCredit = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'Apelido (opcional)',
                    hintText: 'Ex: Meu Nubank',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final digits = digitsController.text;
                if (digits.length != 4 || int.tryParse(digits) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insira exatamente 4 números')),
                  );
                  return;
                }
                final newCard = PaymentCard(
                  lastFourDigits: digits,
                  brand: brand,
                  isCredit: isCredit,
                  nickname: nicknameController.text.trim().isEmpty
                      ? null
                      : nicknameController.text.trim(),
                );
                ref.read(cardProvider.notifier).addCard(newCard);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
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
