import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.calendarTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.attach_money_outlined),
            selectedIcon: const Icon(Icons.attach_money),
            label: l10n.financeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.healthTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_outlined),
            selectedIcon: const Icon(Icons.menu),
            label: l10n.menuTitle,
          ),
        ],
      ),
    );
  }
}
