import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/diets/domain/models/diet_meal.dart';
import 'package:love_routine_app/features/diets/presentation/providers/diet_provider.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';

class FastingTrackerWidget extends ConsumerWidget {
  const FastingTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dietsAsync = ref.watch(dietProvider);
    final theme = Theme.of(context);

    return dietsAsync.when(
      data: (meals) {
        if (meals.isEmpty) return const SizedBox.shrink();

        final fastingInfo = _calculateFasting(meals);
        if (fastingInfo == null) {
          return const SizedBox.shrink();
        }

        final hours = fastingInfo['hours'] as int;
        final minutes = fastingInfo['minutes'] as int;
        final lastMeal = fastingInfo['lastMeal'] as DietMeal;
        final nextMeal = fastingInfo['nextMeal'] as DietMeal;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Período de Jejum',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$hours h ${minutes > 0 ? '$minutes min' : ''}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'De: ${lastMeal.name} (${_formatTime(lastMeal.time)})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Até: ${nextMeal.name} (${_formatTime(nextMeal.time)})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? _calculateFasting(List<DietMeal> meals) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final today = now;
    final tomorrow = now.add(const Duration(days: 1));

    // Get meals scheduled for Yesterday
    // Note: This logic assumes 'meals' are templates that recur.
    // We need to filter which templates happen on specific days.

    // Last meal of yesterday (or today if currently late?)
    // User requested: "entre a ultima refeição de um dia e a primeira refeição do dia seguinte"
    // So typically: Last meal of Yesterday vs First meal of Today.

    final yesterdayMeals = _getMealsForDay(meals, yesterday);
    final todayMeals = _getMealsForDay(meals, today);
    // If no meals today, maybe check tomorrow?
    final tomorrowMeals = _getMealsForDay(meals, tomorrow);

    if (yesterdayMeals.isEmpty)
      return null; // Can't calc specific period without yesterday

    // Sort
    yesterdayMeals.sort((a, b) => _compareTime(a.time, b.time));
    todayMeals.sort((a, b) => _compareTime(a.time, b.time));
    tomorrowMeals.sort((a, b) => _compareTime(a.time, b.time));

    final lastYesterday = yesterdayMeals.last;

    // Find next meal relative to NOW or just First of Today?
    // "Calculated fasting period" usually implies "Overnight Fast".
    // So Last of Yesterday -> First of Today.

    DietMeal? next;
    DateTime? nextDateTime;
    DateTime lastDateTime = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      lastYesterday.time.hour,
      lastYesterday.time.minute,
    );

    if (todayMeals.isNotEmpty) {
      next = todayMeals.first;
      nextDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        next.time.hour,
        next.time.minute,
      );

      // If the "First meal of today" is earlier than "Last meal of yesterday" (impossible in absolute time, but theoretically checking bounds)
      // Actually strictly time-wise:
      // If today is Monday, Yesterday Sunday.
      // SundayDinner 20:00. MondayBreakfast 08:00. Diff 12h.
    } else if (tomorrowMeals.isNotEmpty) {
      // Maybe user skips a whole day?
      next = tomorrowMeals.first;
      nextDateTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        next.time.hour,
        next.time.minute,
      );
    }

    if (next != null && nextDateTime != null) {
      final diff = nextDateTime.difference(lastDateTime);
      // Only valid if positive
      if (diff.inMinutes > 0) {
        return {
          'hours': diff.inHours,
          'minutes': diff.inMinutes % 60,
          'lastMeal': lastYesterday,
          'nextMeal': next,
        };
      }
    }

    return null;
  }

  int _compareTime(DateTime a, DateTime b) {
    if (a.hour != b.hour) return a.hour.compareTo(b.hour);
    return a.minute.compareTo(b.minute);
  }

  List<DietMeal> _getMealsForDay(List<DietMeal> allMeals, DateTime day) {
    return allMeals.where((meal) {
      if (isSameDay(meal.startDate, day))
        return true; // One off? startDate might act as one-off or start of recurrence
      // Actually LogicProvider has better logic, blindly copying recurrence logic here
      if (meal.recurrence == RecurrenceType.daily) return true;
      if (meal.recurrence == RecurrenceType.weekly &&
          meal.startDate.weekday == day.weekday)
        return true;
      if (meal.recurrence == RecurrenceType.custom &&
          (meal.customDaysOfWeek?.contains(day.weekday) ?? false))
        return true;
      return false;
    }).toList();
  }

  // Helper for same day check
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
