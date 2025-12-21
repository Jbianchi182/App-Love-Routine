import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/diets/domain/models/diet_meal.dart';
import 'package:love_routine_app/features/diets/domain/enums/diet_tag.dart';

class DietDialog extends ConsumerStatefulWidget {
  final DietMeal? meal;

  const DietDialog({super.key, this.meal});

  @override
  ConsumerState<DietDialog> createState() => _DietDialogState();
}

class _DietDialogState extends ConsumerState<DietDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _foodItemController;
  
  List<String> _foods = [];
  final List<DietTag> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    _nameController = TextEditingController(text: meal?.name);
    _descriptionController = TextEditingController(text: meal?.description);
    _foodItemController = TextEditingController();
    
    if (meal != null) {
      _foods = List.from(meal.foodItems);
      _selectedTags.addAll(meal.tags);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _foodItemController.dispose();
    super.dispose();
  }

  void _addFoodItem() {
    final text = _foodItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _foods.add(text);
        _foodItemController.clear();
      });
    }
  }

  void _removeFoodItem(int index) {
    setState(() {
      _foods.removeAt(index);
    });
  }

  void _toggleTag(DietTag tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.meal == null ? 'Novo Plano Alimentar' : 'Editar Plano'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Refeição'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição (Opcional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Etiquetas',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: DietTag.values.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag.label),
                    selected: isSelected,
                    onSelected: (_) => _toggleTag(tag),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
               Text(
                'Alimentos',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _foodItemController,
                      decoration: const InputDecoration(
                        labelText: 'Adicionar alimento',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addFoodItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _addFoodItem,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_foods.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Nenhum alimento adicionado.'),
                )
              else
                ..._foods.asMap().entries.map((entry) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeFoodItem(entry.key),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saveMeal,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      if (_foods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicione pelo menos um alimento.')),
        );
        return;
      }

      final meal = widget.meal ?? DietMeal();
      meal
        ..name = _nameController.text
        ..description = _descriptionController.text
        ..foodItems = _foods
        ..tags = _selectedTags;

      Navigator.pop(context, meal);
    }
  }
}
