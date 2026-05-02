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
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  trip.marketName ?? 'Mercado Desconhecido',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('dd/MM/yyyy HH:mm').format(trip.date)} • R\$ ${trip.totalAmount.toStringAsFixed(2)}',
                    ),
                    if (trip.paymentMethodId != null)
                      Text(
                        'Pago com: ${trip.paymentMethodId}${trip.lastFourDigits != null ? " (**** ${trip.lastFourDigits})" : ""}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                  ],
                ),
                children: [
                  const Divider(),
                  ...trip.items.map((item) {
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text(
                        'Qtd: ${item.quantity} • R\$ ${(item.price ?? 0).toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        'R\$ ${((item.price ?? 0) * item.quantity).toStringAsFixed(2)}',
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _confirmDelete(context, ref, trip),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Excluir Histórico', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Registro?'),
        content: const Text('Esta ação não pode ser desfeita. O registro da compra será removido do histórico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(shoppingProvider.notifier).deleteTrip(trip);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
