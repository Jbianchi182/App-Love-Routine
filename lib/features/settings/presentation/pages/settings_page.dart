import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:love_routine_app/config/theme.dart';
import 'package:love_routine_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_preferences_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Personalização da Home'),
          _buildHomePreferences(context, ref),

          const Divider(height: 32),

          // Settings Section
          _buildSectionHeader(context, l10n.settingsTitle),
          _buildSectionHeader(context, l10n.themeTitle),
          Card(
            child: Column(
              children: AppThemeType.values.map((type) {
                return RadioListTile<AppThemeType>(
                  title: Text(_getThemeName(type)),
                  value: type,
                  groupValue: settings.themeType,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.setTheme(value);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, l10n.languageTitle),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Português'),
                  value: 'pt',
                  groupValue: settings.locale.languageCode,
                  onChanged: (value) {
                    if (value != null) notifier.setLocale(const Locale('pt'));
                  },
                ),
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: settings.locale.languageCode,
                  onChanged: (value) {
                    if (value != null) notifier.setLocale(const Locale('en'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.rosa:
        return 'Rosa';
      case AppThemeType.salmao:
        return 'Salmão';
      case AppThemeType.verde:
        return 'Verde';
      case AppThemeType.claro:
        return 'Claro';
      case AppThemeType.escuro:
        return 'Escuro';
    }
  }

  Widget _buildHomePreferences(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(homePreferencesProvider);
    final notifier = ref.read(homePreferencesProvider.notifier);

    return prefsAsync.when(
      data: (prefs) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Text(
                'Ordem das Seções',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: prefs.sectionOrder.map((section) {
                  return ListTile(
                    key: ValueKey(section),
                    title: Text(_getSectionName(section)),
                    trailing: const Icon(Icons.drag_handle),
                  );
                }).toList(),
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final newOrder = List<String>.from(prefs.sectionOrder);
                  final item = newOrder.removeAt(oldIndex);
                  newOrder.insert(newIndex, item);
                  notifier.updateSectionOrder(newOrder);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationOrder(context, ref),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Text(
                'Dias de "Próximas Rotinas"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mostrar eventos para os próximos:'),
                        Text(
                          '${prefs.upcomingDaysRange} dias',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: prefs.upcomingDaysRange.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '${prefs.upcomingDaysRange} dias',
                      onChanged: (value) {
                        notifier.updateUpcomingDays(value.toInt());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Erro ao carregar preferências: $e'),
    );
  }

  Widget _buildNavigationOrder(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(homePreferencesProvider);
    final notifier = ref.read(homePreferencesProvider.notifier);

    return prefsAsync.when(
      data: (prefs) {
        // Full list of available modules to sort
        const allModules = [
          'calendar',
          'finance',
          'health',
          'education',
          'diet',
          'shopping',
        ];

        // Current pinned list might be partial or contain old data.
        // We merge with allModules to ensure we show everything.
        final currentList = List<String>.from(prefs.pinnedModules);

        // Add missing modules to the end
        for (final m in allModules) {
          if (!currentList.contains(m)) currentList.add(m);
        }

        // Remove invalid ones
        currentList.removeWhere((m) => !allModules.contains(m));

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Text(
                'Personalizar Menu Inferior (Top 3 aparecem)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                header: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Arraste para reordenar. Os 3 primeiros serão fixados no menu.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                children: currentList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final module = entry.value;
                  final isPinned = index < 3;

                  return ListTile(
                    key: ValueKey(module),
                    leading: Icon(
                      isPinned ? Icons.push_pin : Icons.circle_outlined,
                      color: isPinned
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: Text(_getModuleName(module)),
                    trailing: const Icon(Icons.drag_handle),
                  );
                }).toList(),
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final newOrder = List<String>.from(currentList);
                  final item = newOrder.removeAt(oldIndex);
                  newOrder.insert(newIndex, item);
                  notifier.updatePinnedModules(newOrder); // Save full list
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _getModuleName(String module) {
    switch (module) {
      case 'calendar':
        return 'Calendário';
      case 'finance':
        return 'Finanças';
      case 'health':
        return 'Saúde';
      case 'education':
        return 'Estudos';
      case 'diet':
        return 'Dieta';
      case 'shopping':
        return 'Mercado';
      default:
        return module;
    }
  }

  String _getSectionName(String section) {
    switch (section) {
      case 'finance':
        return 'Resumo Financeiro';
      case 'calendar':
        return 'Calendário Mês';
      case 'upcoming':
        return 'Próximos Eventos';
      default:
        return section;
    }
  }
}
