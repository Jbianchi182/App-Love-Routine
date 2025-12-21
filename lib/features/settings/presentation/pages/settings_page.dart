import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/config/theme.dart';
import 'package:love_routine_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
}
