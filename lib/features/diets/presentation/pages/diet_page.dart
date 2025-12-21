import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/diets/domain/models/diet_meal.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/diets/presentation/widgets/diet_dialog.dart';
import 'package:love_routine_app/features/diets/presentation/widgets/fasting_tracker_widget.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';

class DietPage extends ConsumerWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dietsAsync = ref.watch(dietProvider);
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar removed for tab integration
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDietDialog(context, ref),
        label: const Text('Novo Plano'),
        icon: const Icon(Icons.add),
      ),
      body: dietsAsync.when(
        data: (diets) {
          if (diets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum plano alimentar criado.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie refeições personalizadas para organizar sua dieta.',
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const FastingTrackerWidget();
              }
              final meal = diets[index - 1];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.tertiaryContainer,
                        child: Icon(
                          Icons.restaurant,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      title: Text(
                        meal.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        meal.tags.map((e) => e.label).join(', '),
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'schedule',
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, size: 20),
                                SizedBox(width: 8),
                                Text('Agendar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showDietDialog(context, ref, meal: meal);
                          } else if (value == 'delete') {
                            _confirmDelete(context, ref, meal);
                          } else if (value == 'schedule') {
                            _scheduleMeal(context, ref, meal);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              meal.foodItems.join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
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
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Future<void> _showDietDialog(
    BuildContext context,
    WidgetRef ref, {
    DietMeal? meal,
  }) async {
    final result = await showDialog<DietMeal>(
      context: context,
      builder: (context) => DietDialog(meal: meal),
    );

    if (result != null) {
      if (meal == null) {
        await ref.read(dietProvider.notifier).addDietMeal(result);
      } else {
        await ref.read(dietProvider.notifier).updateDietMeal(result);
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DietMeal meal,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Plano'),
        content: Text('Deseja excluir "${meal.name}"?'),
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
      await ref.read(dietProvider.notifier).deleteDietMeal(meal);
    }
  }

  Future<void> _scheduleMeal(
    BuildContext context,
    WidgetRef ref,
    DietMeal meal,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 08, minute: 00),
      );

      if (pickedTime != null && context.mounted) {
        final scheduleTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Create a Routine from the Diet Meal
        final routine = Routine()
          ..title = "Refeição: ${meal.name}"
          ..description =
              "Plano: ${meal.tags.map((t) => t.label).join(', ')}\nItens: ${meal.foodItems.join(', ')}"
          ..startDate = scheduleTime
          ..time = scheduleTime
          ..endDate = null
          ..recurrence = RecurrenceType
              .none // Can be improved to allow recurring meals
          ..status = RoutineStatus.pending
          ..history = [];

        await ref.read(routineProvider.notifier).addRoutine(routine);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Refeição agendada para ${pickedDate.day}/${pickedDate.month}!',
              ),
            ),
          );
        }
      }
    }
  }
}
