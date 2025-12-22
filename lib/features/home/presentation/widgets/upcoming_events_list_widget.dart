import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/health/presentation/providers/health_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/calendar_logic_provider.dart';
import 'package:love_routine_app/features/calendar/domain/models/calendar_event.dart';
import 'package:intl/intl.dart';

class UpcomingEventsListWidget extends ConsumerWidget {
  final int daysToShow;

  const UpcomingEventsListWidget({super.key, this.daysToShow = 7});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers to trigger rebuilds
    ref.watch(routineProvider);
    ref.watch(dietProvider);
    ref.watch(medicationProvider);
    ref.watch(appointmentProvider);

    final logic = ref.read(calendarLogicProvider);
    final now = DateTime.now();

    // Collect events for the next 'daysToShow' days
    final List<CalendarEvent> allEvents = [];
    for (int i = 0; i < daysToShow; i++) {
      final date = now.add(Duration(days: i));
      final events = logic.getEventsForDay(date);
      allEvents.addAll(events);
    }

    // Filter and Sort
    // Filter out past completed events or past pending events if only showing future?
    // User said "Proximos eventos".
    final futureEvents = allEvents.where((e) {
      if (e.isCompleted) return false; // Hide completed
      // If today, hide passed time? Or show all remaining today?
      // Simple logic: if start time is AFTER now (minus buffer)
      if (e.time.year == now.year &&
          e.time.month == now.month &&
          e.time.day == now.day) {
        return e.time.isAfter(now.subtract(const Duration(minutes: 15)));
      }
      return e.time.isAfter(now);
    }).toList();

    // Sort by time
    futureEvents.sort((a, b) {
      // Compare full timestamps
      return a.time.compareTo(b.time);
    });

    // Limit to reasonable number? Or show all within range?
    // User said "escolher quanto tempo deve aparecer". So range implies showing all within that range.

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Próximos $daysToShow dias',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (futureEvents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nada agendado para os próximos dias.'),
              ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: futureEvents.length,
              itemBuilder: (context, index) {
                final event = futureEvents[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColorForType(
                        event.type,
                        theme,
                      ).withOpacity(0.2),
                      child: Icon(
                        _getIconForType(event.type),
                        color: _getColorForType(event.type, theme),
                      ),
                    ),
                    title: Text(event.title),
                    subtitle: Text(
                      '${DateFormat('dd/MM').format(event.time)} - ${DateFormat('HH:mm').format(event.time)}',
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getColorForType(CalendarEventType type, ThemeData theme) {
    switch (type) {
      case CalendarEventType.routine:
        return theme.colorScheme.primary;
      case CalendarEventType.diet:
        return Colors.green;
      case CalendarEventType.medication:
        return Colors.redAccent;
      case CalendarEventType.appointment:
        return Colors.blue;
    }
  }

  IconData _getIconForType(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.routine:
        return Icons.event_available;
      case CalendarEventType.diet:
        return Icons.restaurant;
      case CalendarEventType.medication:
        return Icons.medication;
      case CalendarEventType.appointment:
        return Icons.medical_services;
    }
  }
}
