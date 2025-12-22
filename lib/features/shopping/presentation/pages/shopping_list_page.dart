import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_item.dart';
import 'package:love_routine_app/features/shopping/presentation/providers/shopping_provider.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoppingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/menu/shopping/history'),
            tooltip: 'Histórico de Compras',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Sua lista está vazia.\nAdicione itens com o botão +',
                textAlign: TextAlign.center,
              ),
            );
          }

          final sortedItems = List<ShoppingItem>.from(items)
            ..sort((a, b) {
              if (a.isBought == b.isBought) return 0;
              return a.isBought ? 1 : -1;
            });

          double total = 0;
          int boughtCount = 0;
          for (var item in items) {
            if (item.isBought) {
              boughtCount++;
              if (item.price != null) {
                total += item.price! * item.quantity;
              }
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedItems.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    return _ShoppingItemTile(item: item);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$boughtCount/${items.length} comprados',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          'Total: R\$ ${total.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: boughtCount > 0
                            ? () => _confirmFinalize(context, ref, total)
                            : null,
                        child: const Text('Finalizar Compra'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Future<void> _confirmFinalize(
    BuildContext context,
    WidgetRef ref,
    double total,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Compra'),
        content: Text(
          'Deseja finalizar a compra?\n\n'
          'Total: R\$ ${total.toStringAsFixed(2)}\n\n'
          'Os itens marcados serão movidos para o histórico. '
          'Os itens não marcados permanecerão na lista.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(shoppingProvider.notifier).finalizePurchase();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra finalizada e salva no histórico!'),
          ),
        );
      }
    }
  }

  Future<void> _showItemDialog(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem? item,
  ) async {
    final isEditing = item != null;
    final textController = TextEditingController(text: item?.name ?? '');
    int quantity = item?.quantity ?? 1;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Editar Item' : 'Adicionar Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Nome do Item'),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: !isEditing,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() => quantity++);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    if (isEditing) {
                      item!.name = textController.text.trim();
                      item.quantity = quantity;
                      ref.read(shoppingProvider.notifier).updateItem(item);
                    } else {
                      final newItem = ShoppingItem(
                        name: textController.text.trim(),
                        quantity: quantity,
                      );
                      ref.read(shoppingProvider.notifier).addItem(newItem);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Salvar' : 'Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShoppingItemTile extends ConsumerStatefulWidget {
  final ShoppingItem item;

  const _ShoppingItemTile({required this.item});

  @override
  ConsumerState<_ShoppingItemTile> createState() => _ShoppingItemTileState();
}

class _ShoppingItemTileState extends ConsumerState<_ShoppingItemTile> {
  late TextEditingController _priceController;
  final FocusNode _priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.price?.toStringAsFixed(2) ?? '',
    );
    _priceFocus.addListener(_onPriceFocusChange);
  }

  @override
  void didUpdateWidget(covariant _ShoppingItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.price != oldWidget.item.price) {
      if (!_priceFocus.hasFocus) {
        _priceController.text = widget.item.price?.toStringAsFixed(2) ?? '';
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocus.removeListener(_onPriceFocusChange);
    _priceFocus.dispose();
    super.dispose();
  }

  void _onPriceFocusChange() {
    if (!_priceFocus.hasFocus) {
      _savePrice();
    }
  }

  void _savePrice() {
    final text = _priceController.text.replaceAll(',', '.');
    final price = double.tryParse(text);
    if (price != null) {
      ref.read(shoppingProvider.notifier).updatePrice(widget.item, price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: item.isBought,
        onChanged: (val) {
          ref.read(shoppingProvider.notifier).toggleStatus(item);
        },
      ),
      title: InkWell(
        onTap: () {
          // Open edit dialog via parent widget's method approach
          // Since we are in a sub-widget, we need to find the parent or lift the state?
          // Simplest is to copy helper or pass callback.
          // Re-instantiating logic here for simplicity or accessing via provider calls.
          // Wait, _showItemDialog is private in ShoppingListPage.
          // Let's assume user taps "Title" to edit.
          // WE NEED TO CALL _showItemDialog.
          // Since it's private in another class, let's just create a public static or move it.
          // Better: just duplicate logic or make it static.
          ShoppingListPageState.showEditDialog(context, ref, item);
        },
        child: Text(
          item.name,
          style: TextStyle(
            decoration: item.isBought ? TextDecoration.lineThrough : null,
            color: item.isBought ? Colors.grey : null,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.remove, size: 20),
            onPressed: () {
              if (item.quantity > 1) {
                item.quantity--;
                ref.read(shoppingProvider.notifier).updateItem(item);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('${item.quantity}'),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              item.quantity++;
              ref.read(shoppingProvider.notifier).updateItem(item);
            },
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: _priceController,
              focusNode: _priceFocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: 'R\$ ',
                isDense: true,
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _savePrice(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () {
              ref.read(shoppingProvider.notifier).deleteItem(item);
            },
          ),
        ],
      ),
    );
  }
}

// Helper class to expose dialog
class ShoppingListPageState {
  static Future<void> showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem? item,
  ) async {
    // (Copy of _showItemDialog logic)
    final isEditing = item != null;
    final textController = TextEditingController(text: item?.name ?? '');
    int quantity = item?.quantity ?? 1;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Editar Item' : 'Adicionar Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Nome do Item'),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: !isEditing,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() => quantity++);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    if (isEditing) {
                      item!.name = textController.text.trim();
                      item.quantity = quantity;
                      ref.read(shoppingProvider.notifier).updateItem(item);
                    } else {
                      final newItem = ShoppingItem(
                        name: textController.text.trim(),
                        quantity: quantity,
                      );
                      ref.read(shoppingProvider.notifier).addItem(newItem);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Salvar' : 'Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
