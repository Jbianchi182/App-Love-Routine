import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/diets/domain/models/fasting_routine.dart';
import 'package:love_routine_app/features/diets/presentation/providers/fasting_provider.dart';
import 'package:love_routine_app/features/diets/presentation/widgets/fasting_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';

class FastingTrackerWidget extends ConsumerStatefulWidget {
  const FastingTrackerWidget({super.key});

  @override
  ConsumerState<FastingTrackerWidget> createState() => _FastingTrackerWidgetState();
}

class _FastingTrackerWidgetState extends ConsumerState<FastingTrackerWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update UI every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fastingAsync = ref.watch(fastingProvider);
    final theme = Theme.of(context);

    return fastingAsync.when(
      data: (routines) {
        final activeRoutine = routines.cast<FastingRoutine?>().firstWhere(
              (r) => r?.isActive == true,
              orElse: () => null,
            );

        if (activeRoutine == null) return const SizedBox.shrink();

        // Check if there's a fast scheduled for today or spanning into today
        final fastingInfo = _calculateCurrentState(activeRoutine);
        if (fastingInfo == null) return const SizedBox.shrink();

        final isFasting = fastingInfo['isFasting'] as bool;
        final start = fastingInfo['start'] as DateTime;
        final end = fastingInfo['end'] as DateTime;
        final now = DateTime.now();

        final totalDuration = end.difference(start);
        final elapsed = now.difference(start);
        double progress = elapsed.inMinutes / totalDuration.inMinutes;
        progress = progress.clamp(0.0, 1.0);

        final remaining = end.difference(now);
        final remainingHours = remaining.inHours;
        final remainingMinutes = remaining.inMinutes % 60;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          color: isFasting 
              ? theme.colorScheme.primaryContainer 
              : Colors.green.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isFasting ? Icons.timer : Icons.restaurant,
                          color: isFasting ? theme.colorScheme.onPrimaryContainer : Colors.green[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activeRoutine.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isFasting ? theme.colorScheme.onPrimaryContainer : Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editFasting(context, ref, activeRoutine),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _deleteFasting(context, ref, activeRoutine),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFasting ? theme.colorScheme.primary : Colors.green,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isFasting ? 'Tempo restante de Jejum' : 'Janela de Alimentação',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '$remainingHours h ${remainingMinutes} min',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isFasting ? theme.colorScheme.onPrimaryContainer : Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Até ${_formatTime(end)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
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

  Future<void> _editFasting(BuildContext context, WidgetRef ref, FastingRoutine routine) async {
    final result = await showDialog<FastingRoutine>(
      context: context,
      builder: (context) => FastingDialog(routine: routine),
    );
    if (result != null) {
      ref.read(fastingProvider.notifier).updateFastingRoutine(result);
    }
  }

  Future<void> _deleteFasting(BuildContext context, WidgetRef ref, FastingRoutine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Jejum'),
        content: const Text('Tem certeza que deseja excluir esta rotina de jejum?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(fastingProvider.notifier).deleteFastingRoutine(routine);
    }
  }

  // Calculate if we are currently fasting or in eating window based on the active routine
  Map<String, dynamic>? _calculateCurrentState(FastingRoutine routine) {
    final now = DateTime.now();
    
    // We need to check if a fast started yesterday and is still going, 
    // or if a fast started today, etc.
    
    // Let's get the theoretical start time for today, yesterday and tomorrow
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    final possibleStarts = [yesterday, now, tomorrow].where((day) {
      // Check recurrence
      if (routine.recurrence == RecurrenceType.daily) return true;
      if (routine.recurrence == RecurrenceType.weekly && routine.startDate.weekday == day.weekday) return true;
      if (routine.recurrence == RecurrenceType.custom && (routine.customDaysOfWeek?.contains(day.weekday) ?? false)) return true;
      if (routine.recurrence == RecurrenceType.monthly && (routine.customDaysOfMonth?.contains(day.day) ?? false)) return true;
      return false;
    }).map((day) {
      return DateTime(day.year, day.month, day.day, routine.startTime.hour, routine.startTime.minute);
    }).toList();

    // Find the current active period (either fasting or eating window following the fast)
    for (var fastStart in possibleStarts) {
      final fastEnd = fastStart.add(Duration(hours: routine.fastingHours));
      final eatingWindowEnd = fastStart.add(const Duration(hours: 24)); // Until next potential fast

      if (now.isAfter(fastStart) && now.isBefore(fastEnd)) {
        return {
          'isFasting': true,
          'start': fastStart,
          'end': fastEnd,
        };
      } else if (now.isAfter(fastEnd) && now.isBefore(eatingWindowEnd)) {
        return {
          'isFasting': false,
          'start': fastEnd,
          'end': eatingWindowEnd,
        };
      }
    }
    
    return null;
  }
}
