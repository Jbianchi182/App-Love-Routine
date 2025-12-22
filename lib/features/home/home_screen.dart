import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_provider.dart';
import 'package:love_routine_app/features/home/presentation/widgets/custom_task_card.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_preferences_provider.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';
import 'package:love_routine_app/features/home/presentation/widgets/financial_summary_widget.dart';
import 'package:love_routine_app/features/home/presentation/widgets/home_calendar_widget.dart';
import 'package:love_routine_app/features/calendar/domain/models/calendar_event.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
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
    final now = DateTime.now();
    final dateString = DateFormat("EEE, d 'de' MMMM", 'pt_BR').format(now);
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
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: HomeCalendarWidget(),
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
    ref.watch(medicationProvider);
    ref.watch(appointmentProvider);

    final logic = ref.read(calendarLogicProvider);
    final now = DateTime.now();
    final daysToShow =
        ref.read(homePreferencesProvider).asData?.value.upcomingDaysRange ?? 7;

    final List<CalendarEvent> allEvents = [];
    for (int i = 0; i < daysToShow; i++) {
      final date = now.add(Duration(days: i));
      final events = logic.getEventsForDay(date);
      allEvents.addAll(events);
    }

    final futureEvents = allEvents.where((e) {
      if (e.isCompleted) return false;
      if (e.time.year == now.year &&
          e.time.month == now.month &&
          e.time.day == now.day) {
        return e.time.isAfter(now.subtract(const Duration(minutes: 15)));
      }
      return e.time.isAfter(now);
    }).toList();

    futureEvents.sort((a, b) => a.time.compareTo(b.time));

    if (futureEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Nada agendado para os próximos dias.'),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: futureEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = futureEvents[index];
        return CustomTaskCard(
          title: event.title,
          time: DateFormat(
            "EEE, dd 'de' MMMM • HH:mm",
            'pt_BR',
          ).format(event.time),
          backgroundImagePath: event.cardStyle != null
              ? CardStyles.getAsset(event.cardStyle)
              : null,
          isCompleted: event.isCompleted,
          onCheckboxChanged: (val) {
            if (event.originalObject is Routine) {
              final routine = event.originalObject as Routine;
              final newStatus = val == true
                  ? RoutineStatus.completedOnTime
                  : RoutineStatus.pending;
              ref
                  .read(routineProvider.notifier)
                  .updateStatus(routine, newStatus);
            }
          },
          onTap: () async {
            if (event.originalObject is Routine) {
              final routine = event.originalObject as Routine;
              await showDialog(
                context: context,
                builder: (context) => RoutineDialog(routine: routine),
              );
              // Refresh happens via provider watch
            }
          },
        );
      },
    );
  }
}
