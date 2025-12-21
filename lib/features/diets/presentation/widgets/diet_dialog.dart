import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/diets/domain/models/diet_meal.dart';
import 'package:love_routine_app/features/diets/domain/enums/diet_tag.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:table_calendar/table_calendar.dart';

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

  // Recurrence
  RecurrenceType _recurrence = RecurrenceType.daily;
  Set<int> _selectedDays = {};
  Set<int> _selectedMonthDays = {};

  // Time State
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    _nameController = TextEditingController(text: meal?.name);
    _descriptionController = TextEditingController(text: meal?.description);
    _foodItemController = TextEditingController();

    // Initialize time (default to now if new)
    _time = meal?.time ?? DateTime.now();

    if (meal != null) {
      _foods = List.from(meal.foodItems);
      _selectedTags.addAll(meal.tags);
      _recurrence = meal.recurrence;
      if (meal.customDaysOfWeek != null) {
        _selectedDays.addAll(meal.customDaysOfWeek!);
      }
      if (meal.customDaysOfMonth != null) {
        _selectedMonthDays.addAll(meal.customDaysOfMonth!);
      }
    }
  }

  // ... dispose ...

  Future<void> _pickTime() async {
    final timeOfDay = TimeOfDay.fromDateTime(_time);
    final picked = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (picked != null) {
      setState(() {
        _time = DateTime(
          _time.year,
          _time.month,
          _time.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  // ... (dispose and other methods) ...

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
      title: Text(
        widget.meal == null ? 'Novo Plano Alimentar' : 'Editar Plano',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Refeição',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),

              // Time Picker
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Horário da Refeição',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Recurrence Section
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrence,
                decoration: const InputDecoration(labelText: 'Recorrência'),
                items: const [
                  DropdownMenuItem(
                    value: RecurrenceType.daily,
                    child: Text('Diariamente'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceType.weekly,
                    child: Text('Semanalmente'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceType.monthly,
                    child: Text('Mensalmente (Dias Específicos)'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceType.custom,
                    child: Text('Personalizado (Dias da Semana)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _recurrence = value);
                },
              ),
              if (_recurrence == RecurrenceType.monthly) ...[
                const SizedBox(height: 8),
                Text('Dias do Mês', style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  currentDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  headerVisible: true,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                  ),
                  selectedDayPredicate: (day) {
                    return _selectedMonthDays.contains(day.day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (_selectedMonthDays.contains(selectedDay.day)) {
                        _selectedMonthDays.remove(selectedDay.day);
                      } else {
                        _selectedMonthDays.add(selectedDay.day);
                      }
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    defaultDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
              if (_recurrence == RecurrenceType.custom) ...[
                const SizedBox(height: 8),
                Text('Dias da Semana', style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: List.generate(7, (index) {
                    final dayIndex = index + 1; // 1 = Monday
                    final isSelected = _selectedDays.contains(dayIndex);
                    return FilterChip(
                      label: Text(
                        [
                          'Seg',
                          'Ter',
                          'Qua',
                          'Qui',
                          'Sex',
                          'Sab',
                          'Dom',
                        ][index],
                      ), // Simple labels
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayIndex);
                          } else {
                            _selectedDays.remove(dayIndex);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],

              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (Opcional)',
                ),
                maxLines: 2,
              ),
              // ... (rest of the build method: tags, foods) ...
              const SizedBox(height: 16),
              Text(
                'Etiquetas',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
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
        FilledButton(onPressed: _saveMeal, child: const Text('Salvar')),
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

      if (_recurrence == RecurrenceType.custom && _selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selecione pelo menos um dia para recorrência personalizada.',
            ),
          ),
        );
        return;
      }

      if (_recurrence == RecurrenceType.monthly && _selectedMonthDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione pelo menos um dia do mês.')),
        );
        return;
      }

      final meal = widget.meal ?? DietMeal();
      meal
        ..name = _nameController.text
        ..description = _descriptionController.text
        ..time = _time
        ..foodItems = _foods
        ..tags = _selectedTags
        ..recurrence = _recurrence
        ..customDaysOfWeek = _recurrence == RecurrenceType.custom
            ? _selectedDays.toList()
            : null
        ..customDaysOfMonth = _recurrence == RecurrenceType.monthly
            ? _selectedMonthDays.toList()
            : null;

      Navigator.pop(context, meal);
    }
  }
}
