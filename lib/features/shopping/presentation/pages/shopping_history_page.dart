import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:love_routine_app/features/shopping/presentation/providers/shopping_provider.dart';

class ShoppingHistoryPage extends StatelessWidget {
  const ShoppingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Compras')),
      body: const ShoppingHistoryView(),
    );
  }
}

class ShoppingHistoryView extends ConsumerWidget {
  const ShoppingHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(shoppingHistoryProvider);

    return historyAsync.when(
      data: (trips) {
        if (trips.isEmpty) {
          return const Center(child: Text('Nenhuma compra finalizada ainda.'));
        }

        return ListView.builder(
          itemCount: trips.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return Card(
              child: ExpansionTile(
                title: Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(trip.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Total: R\$ ${trip.totalAmount.toStringAsFixed(2)} • ${trip.items.length} itens',
                ),
                children: trip.items.map((item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      'Qtd: ${item.quantity} • R\$ ${(item.price ?? 0).toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      'R\$ ${((item.price ?? 0) * item.quantity).toStringAsFixed(2)}',
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }
}
