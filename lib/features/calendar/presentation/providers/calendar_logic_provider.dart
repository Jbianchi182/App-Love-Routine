import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/calendar/domain/models/calendar_event.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_provider.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/health/presentation/providers/health_provider.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart'; // Import for RoutineStatus
import 'package:love_routine_app/features/diets/presentation/providers/fasting_provider.dart';
import 'package:table_calendar/table_calendar.dart'; // For isSameDay

// Better approach: A minimal service/provider that logic resides in
final calendarLogicProvider = Provider((ref) => CalendarLogic(ref));

class CalendarLogic {
  final Ref ref;

  CalendarLogic(this.ref);

  List<CalendarEvent> getEventsForDay(DateTime day) {
    final routines = ref.read(routineProvider).asData?.value ?? [];
    final diets = ref.read(dietProvider).asData?.value ?? [];
    final fastings = ref.read(fastingProvider).asData?.value ?? [];
    final medications = ref.read(medicationProvider).asData?.value ?? [];
    final appointments = ref.read(appointmentProvider).asData?.value ?? [];

    List<CalendarEvent> dailyEvents = [];

    // Routines
    for (var routine in routines) {
      bool happens = false;
      if (isSameDay(routine.startDate, day))
        happens = true;
      else if (routine.recurrence == RecurrenceType.daily)
        happens = true;
      else if (routine.recurrence == RecurrenceType.weekly &&
          routine.startDate.weekday == day.weekday)
        happens = true;
      else if (routine.recurrence == RecurrenceType.custom &&
          (routine.customDaysOfWeek?.contains(day.weekday) ?? false))
        happens = true;

      if (happens) {
        // Construct time for this day based on routine time
        final eventTime = DateTime(
          day.year,
          day.month,
          day.day,
          routine.time.hour,
          routine.time.minute,
        );

        dailyEvents.add(
          CalendarEvent(
            id: 'routine_${routine.key}',
            title: routine.title,
            time: eventTime,
            type: CalendarEventType.routine,
            originalObject: routine,
            isCompleted:
                routine.status == RoutineStatus.completedOnTime ||
                routine.status == RoutineStatus.completedLate,
            cardStyle: routine.cardStyle,
          ),
        );
      }
    }

    // Diets
    for (var meal in diets) {
      bool happens = false;
      // Simple logic mirroring routine for now
      // Note: DietMeal startDate/recurrence newly added
      if (isSameDay(meal.startDate, day))
        happens = true;
      else if (meal.recurrence == RecurrenceType.daily)
        happens = true;
      else if (meal.recurrence == RecurrenceType.weekly &&
          meal.startDate.weekday == day.weekday)
        happens = true;
      else if (meal.recurrence == RecurrenceType.custom &&
          (meal.customDaysOfWeek?.contains(day.weekday) ?? false))
        happens = true;
      else if (meal.recurrence == RecurrenceType.monthly &&
          (meal.customDaysOfMonth?.contains(day.day) ?? false))
        happens = true;

      if (happens) {
        // Diet meals usually don't have a fixed time in the simplified model yet?
        // Assuming breakfast/lunch etc order or defaulting to 8am/12pm/7pm?
        // For now using start date time component or just 00:00
        final eventTime = DateTime(
          day.year,
          day.month,
          day.day,
          meal.time.hour,
          meal.time.minute,
        );

        dailyEvents.add(
          CalendarEvent(
            id: 'diet_${meal.key}',
            title: meal.name,
            time: eventTime,
            type: CalendarEventType.diet,
            originalObject: meal,
          ),
        );
      }
    }

    bool _isFastingDay(dynamic fast, DateTime d) {
      if (isSameDay(fast.startDate, d)) return true;
      if (fast.recurrence == RecurrenceType.daily) return true;
      if (fast.recurrence == RecurrenceType.weekly && fast.startDate.weekday == d.weekday) return true;
      if (fast.recurrence == RecurrenceType.custom && (fast.customDaysOfWeek?.contains(d.weekday) ?? false)) return true;
      if (fast.recurrence == RecurrenceType.monthly && (fast.customDaysOfMonth?.contains(d.day) ?? false)) return true;
      return false;
    }

    // Fasting
    for (var fast in fastings) {
      if (!fast.isActive) continue;

      final yesterday = day.subtract(const Duration(days: 1));
      if (_isFastingDay(fast, yesterday)) {
        final startYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day, fast.startTime.hour, fast.startTime.minute);
        final endToday = startYesterday.add(Duration(hours: fast.fastingHours));
        if (isSameDay(endToday, day)) {
          dailyEvents.add(
            CalendarEvent(
              id: 'fast_end_${fast.key}',
              title: 'Final do jejum',
              time: endToday,
              type: CalendarEventType.fasting,
              originalObject: fast,
            ),
          );
        }
      }

      if (_isFastingDay(fast, day)) {
        final startToday = DateTime(day.year, day.month, day.day, fast.startTime.hour, fast.startTime.minute);
        final endTomorrow = startToday.add(Duration(hours: fast.fastingHours));

        dailyEvents.add(
          CalendarEvent(
            id: 'fast_start_${fast.key}',
            title: 'Início do jejum',
            time: startToday,
            type: CalendarEventType.fasting,
            originalObject: fast,
          ),
        );

        if (isSameDay(endTomorrow, day)) {
          dailyEvents.add(
            CalendarEvent(
              id: 'fast_end_sameday_${fast.key}',
              title: 'Final do jejum',
              time: endTomorrow,
              type: CalendarEventType.fasting,
              originalObject: fast,
            ),
          );
        }
      }
    }

    // Medications
    for (var med in medications) {
      // Project doses? Or just show next dose?
      // User asked: "indique os horários das proximas doses"
      // If we want to show historical taken doses, we look at takenHistory.
      // If we want to show FUTURE doses, we extrapolate from last taken or startDate.

      // 1. History
      for (var taken in med.takenHistory) {
        if (isSameDay(taken, day)) {
          dailyEvents.add(
            CalendarEvent(
              id: 'med_taken_${med.key}_${taken.millisecondsSinceEpoch}',
              title: '${med.name} (Tomado)',
              time: taken,
              type: CalendarEventType.medication,
              originalObject: med,
              isCompleted: true,
            ),
          );
        }
      }

      // 2. Projected (Upcoming)
      // If day is today or future
      if (!day.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      )) {
        // We only project a few doses ahead or single next dose?
        // User said "indique os horários das proximas doses" (plural).
        // Let's project for this specific day if it fits the schedule.

        if (med.frequencyHours != null) {
          DateTime baseTime = med.takenHistory.isNotEmpty
              ? med.takenHistory.last
              : med.startDate;
          // Add frequency until we reach 'day'
          while (baseTime.isBefore(day.add(const Duration(days: 1)))) {
            baseTime = baseTime.add(Duration(hours: med.frequencyHours!));
            if (isSameDay(baseTime, day)) {
              dailyEvents.add(
                CalendarEvent(
                  id: 'med_future_${med.key}_${baseTime.millisecondsSinceEpoch}',
                  title: '${med.name} (Dose)',
                  time: baseTime,
                  type: CalendarEventType.medication,
                  originalObject: med,
                  isCompleted: false, // Future
                ),
              );
            }
          }
        }
      }
    }

    // Appointments
    for (var apt in appointments) {
      if (isSameDay(apt.date, day)) {
        dailyEvents.add(
          CalendarEvent(
            id: 'apt_${apt.key}',
            title: '${apt.title} - ${apt.patientName}',
            time: apt.date,
            type: CalendarEventType.appointment,
            originalObject: apt,
          ),
        );
      }
    }

    // Sort by time
    dailyEvents.sort((a, b) => a.time.compareTo(b.time));
    return dailyEvents;
  }
}
