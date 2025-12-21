import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/calendar/domain/models/calendar_event.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';

import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/health/presentation/providers/health_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/calendar_logic_provider.dart';

import 'package:love_routine_app/features/calendar/presentation/widgets/routine_dialog.dart';

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
    // Watch all data streams to trigger rebuilds
    ref.watch(routineProvider);
    ref.watch(dietProvider);
    ref.watch(medicationProvider);
    ref.watch(appointmentProvider);

    final calendarLogic = ref.read(calendarLogicProvider);
    final theme = Theme.of(context);

    // Get events for selected day
    final selectedDate = _selectedDay ?? DateTime.now();
    final dayEvents = calendarLogic.getEventsForDay(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoutineDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            color: Colors.white, // Explicitly white as requested
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
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
                // Determine if there are any events for dots
                return calendarLogic.getEventsForDay(day);
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
          ),
          const SizedBox(height: 8),
          Expanded(
            child: dayEvents.isEmpty
                ? Center(
                    child: Text(
                      'Nada agendado para este dia.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      return _buildEventCard(context, event, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    CalendarEvent event,
    ThemeData theme,
  ) {
    IconData icon;
    Color color;

    switch (event.type) {
      case CalendarEventType.routine:
        icon = Icons.event_available;
        color = theme.colorScheme.primary;
        break;
      case CalendarEventType.diet:
        icon = Icons.restaurant;
        color = Colors.green;
        break;
      case CalendarEventType.medication:
        icon = Icons.medication;
        color = Colors.redAccent;
        break;
      case CalendarEventType.appointment:
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white, // Explicit white background request
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            decoration: event.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(DateFormat('HH:mm').format(event.time)),
        trailing: event.type == CalendarEventType.routine && !event.isCompleted
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () {
                  if (event.originalObject is Routine) {
                    final routine = event.originalObject as Routine;
                    ref
                        .read(routineProvider.notifier)
                        .updateStatus(routine, RoutineStatus.completedOnTime);
                  }
                },
              )
            : null,
        onTap: () {
          if (event.type == CalendarEventType.routine) {
            _showRoutineDialog(
              context,
              routine: event.originalObject as Routine,
            );
          }
          // TODO: Handle taps for other types (edit diet/med)
        },
      ),
    );
  }

  Future<void> _showRoutineDialog(
    BuildContext context, {
    Routine? routine,
  }) async {
    final result = await showDialog<Routine>(
      context: context,
      builder: (context) =>
          RoutineDialog(routine: routine, initialDate: _selectedDay),
    );

    if (result != null) {
      if (routine == null) {
        await ref.read(routineProvider.notifier).addRoutine(result);
      } else {
        await ref.read(routineProvider.notifier).updateRoutine(result);
      }
    }
  }
}
