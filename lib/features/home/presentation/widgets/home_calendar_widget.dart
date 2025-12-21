import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_provider.dart';

class HomeCalendarWidget extends ConsumerWidget {
  const HomeCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final theme = Theme.of(context);

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
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
            rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
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
            // Navigate to calendar tab with specific date details if needed
             context.go('/calendar'); 
          },
          onPageChanged: (focusedDay) {
            notifier.onPageChanged(focusedDay);
          },
          // Mock event loader for markers
          eventLoader: (day) {
            if (day.day % 2 == 0) return ['Event']; // Dummy marker logic
            return [];
          },
          onHeaderTapped: (_) {
            context.go('/calendar');
          },
        ),
      ),
    );
  }
}
