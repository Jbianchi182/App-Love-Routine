import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_provider.dart';
import 'package:love_routine_app/features/home/presentation/widgets/custom_task_card.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_preferences_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_history_provider.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';
import 'package:love_routine_app/features/home/presentation/widgets/financial_summary_widget.dart';
import 'package:love_routine_app/features/home/presentation/widgets/home_calendar_widget.dart';
import 'package:love_routine_app/features/calendar/domain/models/calendar_event.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/fasting_provider.dart';
import 'package:love_routine_app/features/diets/domain/models/fasting_routine.dart';
import 'package:love_routine_app/features/health/presentation/providers/health_provider.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/calendar_logic_provider.dart';
import 'package:love_routine_app/config/card_styles.dart';
import 'package:love_routine_app/features/calendar/presentation/widgets/routine_dialog.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(homeProvider); // Ensure initialization
    final prefsAsync = ref.watch(homePreferencesProvider);
    final homeState = ref.read(homeProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Date Formatting
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final dateString = DateFormat("EEE, d 'de' MMMM", locale).format(now);
    // Capitalize first letter
    final formattedDate = dateString.replaceFirst(
      dateString[0],
      dateString[0].toUpperCase(),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá,', // TODO: Add User Name if available
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),

            // Body Content (Responsive)
            Expanded(
              child: prefsAsync.when(
                data: (prefs) {
                  return _buildResponsiveBody(context, ref, homeState, prefs);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Erro ao carregar')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRoutineDialog(
    BuildContext context,
    WidgetRef ref, {
    Routine? routine,
  }) async {
    final homeState = ref.read(homeProvider);
    final result = await showDialog<Routine>(
      context: context,
      builder: (context) =>
          RoutineDialog(routine: routine, initialDate: homeState.selectedDate),
    );

    if (result != null) {
      if (routine == null) {
        await ref.read(routineProvider.notifier).addRoutine(result);
      } else {
        await ref.read(routineProvider.notifier).updateRoutine(result);
      }
    }
  }

  Widget _buildResponsiveBody(
    BuildContext context,
    WidgetRef ref,
    HomeState homeState,
    HomePreferences prefs,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: prefs.sectionOrder.map((section) {
            if (section == 'upcoming') {
              return _buildUpcomingSection(context, ref);
            }
            if (section == 'finance') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => context.go('/category/finance'),
                  child: FinancialSummaryWidget(
                    income: homeState.income,
                    expense: homeState.expense,
                  ),
                ),
              );
            }
            if (section == 'calendar') {
              return Column(
                children: [
                  HomeCalendarWidget(
                    onDaySelected: (day) {
                      // Always show dialog to add routine when day is selected/tapped
                      // Or maybe only if tapped again? 
                      // User wants to be able to create more than one. 
                      // Let's make it so if they tap the day, it opens the dialog.
                      _showRoutineDialog(context, ref, routine: null);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return Container();
          }).toList(),
        );
      },
    );
  }

  Widget _buildUpcomingSection(BuildContext context, WidgetRef ref) {
    ref.watch(routineProvider);
    ref.watch(dietProvider);
    ref.watch(fastingProvider);
    ref.watch(medicationProvider);
    ref.watch(appointmentProvider);

    final logic = ref.read(calendarLogicProvider);
    final selectedDate = ref.read(homeProvider).selectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysToShow =
        ref.read(homePreferencesProvider).asData?.value.upcomingDaysRange ?? 7;

    final List<CalendarEvent> allEvents = [];
    for (int i = 0; i < daysToShow; i++) {
      final date = selectedDate.add(Duration(days: i));
      final events = logic.getEventsForDay(date);
      allEvents.addAll(events);
    }

    final futureEvents = allEvents; // Show all events for the selected days

    futureEvents.sort((a, b) => a.time.compareTo(b.time));

    if (futureEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Nada agendado para os próximos dias.'),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildGroupedEvents(context, ref, futureEvents, now),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/routine/history'),
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Ver Histórico de Tarefas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedEvents(BuildContext context, WidgetRef ref, List<CalendarEvent> futureEvents, DateTime now) {
    final Map<DateTime, List<CalendarEvent>> groupedEvents = {};
    for (var event in futureEvents) {
      final date = DateTime(event.time.year, event.time.month, event.time.day);
      if (!groupedEvents.containsKey(date)) {
        groupedEvents[date] = [];
      }
      groupedEvents[date]!.add(event);
    }

    final theme = Theme.of(context);
    final List<Widget> widgets = [];

    final entries = groupedEvents.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final date = entries[i].key;
      final events = entries[i].value;

      final today = DateTime(now.year, now.month, now.day);
      String dateLabel;
      if (date == today) {
        dateLabel = 'Hoje:';
      } else if (date == today.add(const Duration(days: 1))) {
        dateLabel = 'Amanhã:';
      } else {
        dateLabel = DateFormat("EEEE, d/M", Localizations.localeOf(context).toString()).format(date);
        dateLabel = '${dateLabel.replaceFirst(dateLabel[0], dateLabel[0].toUpperCase())}:';
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            dateLabel,
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
          ),
        ),
      );

      for (var event in events) {
        if (event.type == CalendarEventType.routine && event.originalObject is Routine) {
          final routine = event.originalObject as Routine;
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Consumer(
              builder: (context, ref, _) {
                final history = ref.watch(routineHistoryProvider).asData?.value ?? [];
                final today = DateTime(now.year, now.month, now.day);
                final isTodayCompleted = history.any((c) => 
                  c.date.isAtSameMomentAs(today) && 
                  c.routineId == routine.key.toString() && 
                  c.isCompleted);

                return CustomTaskCard(
                  title: routine.title,
                  time: DateFormat('HH:mm').format(routine.time),
                  backgroundImagePath: CardStyles.getAsset(routine.cardStyle),
                  imageAlignmentY: routine.imageAlignmentY,
                  fontSize: routine.fontSize,
                  isCompleted: isTodayCompleted,
                  onCheckboxChanged: (val) {
                    final newStatus = val == true
                        ? RoutineStatus.completedOnTime
                        : RoutineStatus.pending;
                    ref.read(routineProvider.notifier).updateStatus(routine.key, newStatus);
                    ref.read(routineHistoryProvider.notifier).logTodayCompletion(routine, val == true);
                  },
                onTap: () {
                  _showRoutineDialog(context, ref, routine: routine);
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Excluir Rotina'),
                      content: Text('Deseja excluir "${routine.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(routineProvider.notifier).deleteRoutine(routine);
                  }
                },
                );
              },
            ),
          ),
          );
        } else {
          // Other event types (diet, medication, etc.) still use the simple row for now
          // or we can use a simpler version of CustomTaskCard
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      DateFormat('HH:mm').format(event.time),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      if (i < entries.length - 1) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildDayEventsList(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    final logic = ref.read(calendarLogicProvider);
    final dayEvents = logic.getEventsForDay(selectedDate);
    final theme = Theme.of(context);

    if (dayEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Nada agendado para este dia.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return _buildEventCard(context, ref, event, theme);
      },
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    WidgetRef ref,
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
      case CalendarEventType.fasting:
        icon = Icons.timer;
        color = Colors.purple;
        break;
    }

    if (event.type == CalendarEventType.routine &&
        event.originalObject is Routine) {
      final routine = event.originalObject as Routine;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Consumer(
          builder: (context, ref, _) {
            final history = ref.watch(routineHistoryProvider).asData?.value ?? [];
            final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final isTodayCompleted = history.any((c) => 
              c.date.isAtSameMomentAs(today) && 
              c.routineId == routine.key.toString() && 
              c.isCompleted);

            return CustomTaskCard(
              title: routine.title,
              time: DateFormat('HH:mm').format(routine.time),
              backgroundImagePath: routine.cardStyle != null
                  ? CardStyles.getAsset(routine.cardStyle)
                  : null,
              imageAlignmentY: routine.imageAlignmentY,
              fontSize: routine.fontSize,
              isCompleted: isTodayCompleted,
              onCheckboxChanged: (val) {
                final newStatus = val == true
                    ? RoutineStatus.completedOnTime
                    : RoutineStatus.pending;
                ref.read(routineProvider.notifier).updateStatus(routine.key, newStatus);
                ref.read(routineHistoryProvider.notifier).logTodayCompletion(routine, val == true);
              },
              onTap: () => _showRoutineDialog(context, ref, routine: routine),
            );
          },
        ),
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
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
      ),
    );
  }
}
