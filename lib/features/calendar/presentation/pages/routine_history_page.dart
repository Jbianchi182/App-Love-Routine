import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:love_routine_app/features/calendar/presentation/providers/routine_history_provider.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine_completion.dart';

class RoutineHistoryPage extends ConsumerWidget {
  const RoutineHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(routineHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Tarefas'),
      ),
      body: historyAsync.when(
        data: (completions) {
          // Filter out today's completions
          final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          final pastCompletions = completions.where((c) => c.date.isBefore(today)).toList();

          if (pastCompletions.isEmpty) {
            return const Center(
              child: Text('Nenhum histórico registrado ainda.'),
            );
          }

          // Group by date
          final Map<DateTime, List<RoutineCompletion>> grouped = {};
          for (var c in pastCompletions) {
            final date = DateTime(c.date.year, c.date.month, c.date.day);
            if (!grouped.containsKey(date)) {
              grouped[date] = [];
            }
            grouped[date]!.add(c);
          }

          final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedDates.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateCompletions = grouped[date]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: Text(
                      DateFormat('EEEE, dd/MM/yyyy').format(date),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Card(
                    child: Column(
                      children: dateCompletions.map((c) {
                        return ListTile(
                          leading: Icon(
                            c.isCompleted ? Icons.check_circle : Icons.cancel,
                            color: c.isCompleted ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            c.routineTitle,
                            style: TextStyle(
                              decoration: c.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text('Horário: ${DateFormat('HH:mm').format(c.scheduledTime)}'),
                          trailing: Text(
                            c.isCompleted ? 'Concluída' : 'Não realizada',
                            style: TextStyle(
                              fontSize: 12,
                              color: c.isCompleted ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
