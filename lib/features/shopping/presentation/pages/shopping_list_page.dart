import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_item.dart';
import 'package:love_routine_app/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:love_routine_app/features/shopping/presentation/providers/shopping_list_provider.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_list_model.dart';
import 'package:love_routine_app/features/finance/presentation/providers/card_provider.dart';
import 'package:love_routine_app/features/finance/domain/models/payment_card.dart';
import 'package:love_routine_app/features/household/presentation/providers/household_provider.dart';
import 'package:love_routine_app/features/household/domain/models/household.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoppingProvider);
    final listsAsync = ref.watch(shoppingListProvider);
    final selectedListId = ref.watch(selectedListIdProvider);
    final theme = Theme.of(context);

    final currentList = listsAsync.value?.isNotEmpty == true
        ? (listsAsync.value!.any((l) => l.id == selectedListId)
            ? listsAsync.value!.firstWhere((l) => l.id == selectedListId)
            : listsAsync.value!.first)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentList?.name ?? 'Compras',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (currentList != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditListDialog(context, ref, currentList),
              tooltip: 'Editar esta lista',
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () => _confirmDeleteList(context, ref, currentList),
              tooltip: 'Excluir esta lista',
            ),
          ],
          TextButton.icon(
            icon: const Icon(Icons.history, size: 20),
            label: const Text('Histórico'),
            onPressed: () => context.push('/shopping/history'),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_item_btn',
            onPressed: currentList != null 
                ? () => ShoppingListPage.showItemDialog(context, ref, null, currentList.id)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar item', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 110), 
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildListSelector(context, ref),
            const Divider(height: 1),
            Expanded(
              child: itemsAsync.when(
                data: (items) {
                  final listItems = items.where((i) => (i.listId ?? 'default') == selectedListId).toList();

                  if (listItems.isEmpty) {
                    return const Center(
                      child: Text(
                        'Esta lista está vazia.\nAdicione itens com o botão +',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final sortedItems = List<ShoppingItem>.from(listItems)
                    ..sort((a, b) {
                      if (a.isBought == b.isBought) return 0;
                      return a.isBought ? 1 : -1;
                    });

                  double total = 0;
                  int boughtCount = 0;
                  for (var item in listItems) {
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
                                  '$boughtCount/${listItems.length} comprados',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSelector(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListProvider);
    final selectedId = ref.watch(selectedListIdProvider);

    return listsAsync.when(
      data: (lists) {
        final personalLists = lists.where((l) => !l.isShared).toList();
        final sharedLists = lists.where((l) => l.isShared).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Personal Section
              if (personalLists.isNotEmpty) ...[
                const Text('Minhas: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                ...personalLists.map((list) => _buildChip(context, ref, list, selectedId)),
                const SizedBox(width: 16),
              ],

              // Shared Section
              if (sharedLists.isNotEmpty) ...[
                const Text('Compartilhadas: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                ...sharedLists.map((list) => _buildChip(context, ref, list, selectedId)),
                const SizedBox(width: 8),
              ],

              // Add Button
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showAddListDialog(context, ref),
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 50),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildChip(BuildContext context, WidgetRef ref, ShoppingList list, String selectedId) {
    final isSelected = list.id == selectedId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(list.name),
            if (list.isShared) ...[
              const SizedBox(width: 4),
              const Icon(Icons.group, size: 14),
            ],
          ],
        ),
        selected: isSelected,
        onSelected: (val) {
          if (val) ref.read(selectedListIdProvider.notifier).state = list.id;
        },
      ),
    );
  }

  void _showEditListDialog(BuildContext context, WidgetRef ref, ShoppingList list) {
    final controller = TextEditingController(text: list.name);
    bool isShared = list.isShared;
    Household? selectedHousehold;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final householdsAsync = ref.watch(userHouseholdsProvider);
          final households = householdsAsync.asData?.value ?? [];

          if (isShared && selectedHousehold == null && list.householdId != null) {
            selectedHousehold = households.cast<Household?>().firstWhere(
                  (h) => h?.id == list.householdId,
                  orElse: () => null,
                );
          }

          return AlertDialog(
            title: const Text('Editar Lista'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Lista',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Compartilhar lista'),
                    value: isShared,
                    onChanged: (val) => setState(() => isShared = val ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (isShared && households.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Household>(
                      value: selectedHousehold,
                      decoration: const InputDecoration(
                        labelText: 'Residência',
                        border: OutlineInputBorder(),
                      ),
                      items: households.map((h) {
                        return DropdownMenuItem(
                          value: h,
                          child: Text(h.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedHousehold = val),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  ref.read(shoppingListProvider.notifier).updateList(
                        list.id,
                        name: controller.text,
                        isShared: isShared,
                        householdId: isShared ? selectedHousehold?.id : null,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddListDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    bool isShared = false;
    Household? selectedHousehold;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final householdsAsync = ref.watch(userHouseholdsProvider);
          final households = householdsAsync.asData?.value ?? [];

          // Auto-select if only one household
          if (households.length == 1 && selectedHousehold == null) {
            selectedHousehold = households.first;
          }

          return AlertDialog(
            title: const Text('Nova Lista'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Lista',
                      hintText: 'Ex: Pet Shop, Farmácia...',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Compartilhar lista'),
                    subtitle: const Text('Membros da residência poderão ver e editar'),
                    value: isShared,
                    onChanged: (val) => setState(() => isShared = val ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (isShared && households.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    if (households.length > 1)
                      DropdownButtonFormField<Household>(
                        value: selectedHousehold,
                        decoration: const InputDecoration(
                          labelText: 'Selecionar Residência',
                          border: OutlineInputBorder(),
                        ),
                        items: households.map((h) {
                          return DropdownMenuItem(
                            value: h,
                            child: Text(h.name),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedHousehold = val),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home_outlined, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Compartilhando com: ${households.first.name}')),
                          ],
                        ),
                      ),
                  ] else if (isShared && households.isEmpty)
                    const Text(
                      'Você não possui residências cadastradas para compartilhar.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    ref.read(shoppingListProvider.notifier).addList(
                      controller.text, 
                      'shopping_basket',
                      isShared: isShared,
                      householdId: isShared ? selectedHousehold?.id : null,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Criar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteList(BuildContext context, WidgetRef ref, ShoppingList list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Lista'),
        content: Text('Tem certeza que deseja excluir a lista "${list.name}" e todos os seus itens?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ref.read(selectedListIdProvider.notifier).state = 'default';
              ref.read(shoppingListProvider.notifier).deleteList(list.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmFinalize(
    BuildContext context,
    WidgetRef ref,
    double total,
  ) async {
    final marketController = TextEditingController();
    String paymentMethod = 'Cartão';
    PaymentCard? selectedCard;

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final cardsAsync = ref.watch(cardProvider);
          final cards = cardsAsync.asData?.value ?? [];

          return AlertDialog(
            title: const Text('Finalizar Compra'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: marketController,
                    decoration: const InputDecoration(
                      labelText: 'Em qual mercado?',
                      hintText: 'Ex: Carrefour, Pão de Açúcar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Forma de Pagamento:'),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: paymentMethod,
                    items: ['Cartão', 'Dinheiro', 'Pix'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => paymentMethod = val);
                    },
                  ),
                  if (paymentMethod == 'Cartão') ...[
                    const SizedBox(height: 16),
                    if (cards.isEmpty)
                      const Text(
                        'Nenhum cartão cadastrado. Cadastre um na aba Finanças.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      )
                    else
                      DropdownButtonFormField<PaymentCard>(
                        value: selectedCard,
                        decoration: const InputDecoration(
                          labelText: 'Selecione o Cartão',
                          border: OutlineInputBorder(),
                        ),
                        items: cards.map((card) {
                          return DropdownMenuItem(
                            value: card,
                            child: Text(card.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => selectedCard = val);
                        },
                      ),
                  ],
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
                  if (marketController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, informe o mercado')),
                    );
                    return;
                  }
                  if (paymentMethod == 'Cartão' && selectedCard == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, selecione um cartão')),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    'market': marketController.text.trim(),
                    'payment': paymentMethod,
                    'digits': selectedCard?.lastFourDigits,
                    'cardInfo': selectedCard?.displayName,
                  });
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      await ref.read(shoppingProvider.notifier).finalizePurchase(
            marketName: result['market']!,
            paymentMethod: result['payment']!,
            lastFourDigits: result['digits'],
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra finalizada e registrada no financeiro!'),
          ),
        );
      }
    }
  }

  static Future<void> showItemDialog(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem? item,
    String? currentListId,
  ) async {
    if (currentListId == null || currentListId == 'default' && (ref.read(shoppingListProvider).value?.isEmpty ?? true)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nenhuma lista disponível'),
          content: const Text('Você precisa criar uma lista de compras antes de adicionar itens.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
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
                        listId: currentListId,
                      );
                      ref.read(shoppingProvider.notifier).addItem(newItem, currentListId ?? 'default');
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
        onTap: () => ShoppingListPage.showItemDialog(context, ref, item, item.listId),
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
