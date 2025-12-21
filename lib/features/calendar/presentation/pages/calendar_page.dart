import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/widgets/routine_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routineProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'), // TODO: Localize
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoutineDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar<Routine>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              return routinesAsync.valueOrNull?.where((routine) {
                // Simple daily check for now, can be improved with recurrence logic
                return isSameDay(routine.startDate, day);
              }).toList() ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: routinesAsync.when(
              data: (routines) {
                final selectedDate = _selectedDay ?? DateTime.now();
                // Filter routines for the selected day
                final daysRoutines = routines.where((routine) {
                   // TODO: Implement proper recurrence checking
                   return isSameDay(routine.startDate, selectedDate);
                }).toList();

                if (daysRoutines.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma rotina para este dia.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: daysRoutines.length,
                  itemBuilder: (context, index) {
                    final routine = daysRoutines[index];
                    return ListTile(
                      title: Text(routine.title),
                      subtitle: Text(DateFormat('HH:mm').format(routine.time)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showRoutineDialog(context, routine: routine),
                      ),
                      onLongPress: () => _confirmDelete(context, routine),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRoutineDialog(BuildContext context, {Routine? routine}) async {
    final result = await showDialog<Routine>(
      context: context,
      builder: (context) => RoutineDialog(
        routine: routine,
        initialDate: _selectedDay,
      ),
    );

    if (result != null) {
      if (routine == null) {
        await ref.read(routineProvider.notifier).addRoutine(result);
      } else {
        await ref.read(routineProvider.notifier).updateRoutine(result);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, Routine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Rotina'),
        content: Text('Deseja excluir "${routine.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(routineProvider.notifier).deleteRoutine(routine.id);
    }
  }
}
