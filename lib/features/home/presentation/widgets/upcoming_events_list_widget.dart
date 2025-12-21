import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/health/presentation/providers/health_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/calendar_logic_provider.dart';

class UpcomingEventsListWidget extends ConsumerWidget {
  const UpcomingEventsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for real data indirectly via Logic?
    // Actually Logic Provider is a Reader, we need to watch the underlying providers to trigger rebuilds.
    // However, getting events requires 'day'.

    // Better strategy: Watch the underlying providers (happens in build) then use Logic to filter for TODAY.
    // We can just watch 'calendarLogicProvider' if it exposed state, but it is a class with methods.
    // The previous code watched 'routineProvider'. Use ref.watch on all relevant providers to trigger rebuild.
    // We can use the same technique as CalendarPage or just watch them here.

    ref.watch(routineProvider);
    ref.watch(dietProvider);
    ref.watch(medicationProvider);
    ref.watch(appointmentProvider);

    final logic = ref.read(calendarLogicProvider);
    final now = DateTime.now();
    final todayEvents = logic.getEventsForDay(now);

    // Filter for pending/future events for today
    final pendingToday = todayEvents
        .where(
          (e) =>
              !e.isCompleted &&
              e.time.isAfter(now.subtract(const Duration(minutes: 30))),
        ) // Show recent future
        .take(5)
        .toList();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Próximas Rotinas', // Quantified to Routines for now
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (pendingToday.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhuma rotina pendente para hoje.'),
              ),
            )
          else
            ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Nested inside other scroll view
              shrinkWrap: true,
              itemCount: pendingToday.length,
              itemBuilder: (context, index) {
                final routine = pendingToday[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.event_note,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    title: Text(routine.title),
                    subtitle: Text(
                      '${routine.time.hour}:${routine.time.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
