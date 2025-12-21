import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/health/presentation/providers/health_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/calendar_logic_provider.dart';

class HomeCalendarWidget extends ConsumerWidget {
  const HomeCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final theme = Theme.of(context);

    // Watch providers for real data - indirectly watched by CalendarLogicProvider internally if we read it?
    // Actually CalendarLogicProvider reads once. We need to watch it or the underlying data.
    // The previous implementation watched routineProvider.
    // We should watch the providers that affect the calendar.
    ref.watch(routineProvider);
    ref.watch(dietProvider);
    ref.watch(medicationProvider);
    ref.watch(appointmentProvider);

    // No need to fetch routines list here, eventLoader handles it.

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: homeState.focusedDate,
          selectedDayPredicate: (day) => isSameDay(homeState.selectedDate, day),
          calendarFormat: CalendarFormat.month,
          locale: Localizations.localeOf(context).languageCode,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
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
          onDaySelected: (selectedDay, focusedDay) {
            notifier.onDaySelected(selectedDay, focusedDay);
            // Navigate to Calendar Page with selected date
            context.go('/calendar');
          },
          onPageChanged: (focusedDay) {
            notifier.onPageChanged(focusedDay);
          },
          eventLoader: (day) {
            // Use unified logic to show dots for ALL events
            final logic = ref.read(calendarLogicProvider);
            return logic.getEventsForDay(day);
          },
          onHeaderTapped: (_) {
            context.go('/calendar');
          },
        ),
      ),
    );
  }
}
