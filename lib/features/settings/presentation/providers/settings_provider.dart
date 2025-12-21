import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/config/theme.dart';

class SettingsState {
  final AppThemeType themeType;
  final Locale locale;

  SettingsState({
    this.themeType = AppThemeType.strawberry,
    this.locale = const Locale('pt'), // Default to Portuguese per user context
  });

  SettingsState copyWith({
    AppThemeType? themeType,
    Locale? locale,
  }) {
    return SettingsState(
      themeType: themeType ?? this.themeType,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState();
  }

  void setTheme(AppThemeType type) {
    state = state.copyWith(themeType: type);
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
