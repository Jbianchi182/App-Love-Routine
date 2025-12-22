import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          // Navigation Section
          _buildSectionHeader(context, 'Acesso Rápido'), // TODO: Localize
          _buildMenuTile(
            context,
            icon: Icons.local_library_outlined,
            title: l10n.educationTitle, // 'Educação'
            color: Colors.orange,
            onTap: () => context.go('/menu/education'),
          ),
          const SizedBox(height: 8),
          _buildMenuTile(
            context,
            icon: Icons.restaurant_menu_outlined,
            title: 'Dieta', // TODO: Localize
            color: Colors.green,
            onTap: () => context.go('/menu/diet'),
          ),
          const SizedBox(height: 8),
          _buildMenuTile(
            context,
            icon: Icons.shopping_cart_outlined,
            title: 'Lista de Compras',
            color: Colors.purple,
            onTap: () => context.go('/menu/shopping'),
          ),

          const Divider(height: 32),

          // Home Preferences Section
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

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
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
      case AppThemeType.strawberry:
        return 'Strawberry Pink';
      case AppThemeType.peach:
        return 'Peach Orange';
      case AppThemeType.sky:
        return 'Sky Blue';
      case AppThemeType.mint:
        return 'Mint Green';
      case AppThemeType.dark:
        return 'Midnight Dark';
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
