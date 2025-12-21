import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_provider.dart';

class UpcomingEventsListWidget extends ConsumerWidget {
  const UpcomingEventsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Próximos Eventos', // TODO: Localize
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (homeState.upcomingEvents.isEmpty)
            const Center(child: Text('Nenhum evento próximo.'))
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(), // Nested inside other scroll view
              shrinkWrap: true,
              itemCount: homeState.upcomingEvents.length,
              itemBuilder: (context, index) {
                final event = homeState.upcomingEvents[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(Icons.event_note, color: theme.colorScheme.secondary),
                    ),
                    title: Text(event),
                    subtitle: const Text('Hoje'), // Placeholder
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
