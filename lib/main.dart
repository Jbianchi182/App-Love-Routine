import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:love_routine_app/config/routes.dart';
import 'package:love_routine_app/config/theme.dart';
import 'package:love_routine_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: LoveRoutineApp()));
}

class LoveRoutineApp extends ConsumerWidget {
  const LoveRoutineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp.router(
      title: 'Love Routine',
      theme: AppTheme.getTheme(settings.themeType),
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
