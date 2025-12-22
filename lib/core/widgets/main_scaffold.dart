import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_preferences_provider.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  static const Map<String, int> branchIndexMap = {
    'home': 0,
    'calendar': 1,
    'finance': 2,
    'health': 3,
    'education': 4,
    'diet': 5,
    'shopping': 6,
    'categories': 7,
    'settings': 8,
  };

  static const Map<String, IconData> iconMap = {
    'home': Icons.home_outlined,
    'calendar': Icons.calendar_month_outlined,
    'finance': Icons.attach_money,
    'health': Icons.favorite_border,
    'education': Icons.school_outlined,
    'diet': Icons.restaurant_menu,
    'shopping': Icons.shopping_cart_outlined,
    'categories': Icons.menu,
    'settings': Icons.settings_outlined,
  };

  static const Map<String, IconData> selectedIconMap = {
    'home': Icons.home,
    'calendar': Icons.calendar_month,
    'finance': Icons.attach_money, // Filled version if available
    'health': Icons.favorite,
    'education': Icons.school,
    'diet': Icons.restaurant,
    'shopping': Icons.shopping_cart,
    'categories': Icons.menu,
    'settings': Icons.settings,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefsAsync = ref.watch(homePreferencesProvider);
    final prefs = prefsAsync.asData?.value ?? HomePreferences();

    // Default pinned modules if empty or error
    final pinned = prefs.pinnedModules.isNotEmpty
        ? prefs.pinnedModules
        : ['calendar', 'finance', 'health'];

    // Ensure we have exactly 3 pinned items, pad with defaults if needed
    final safePinned = List<String>.from(pinned);
    while (safePinned.length < 3) {
      if (!safePinned.contains('calendar'))
        safePinned.add('calendar');
      else if (!safePinned.contains('finance'))
        safePinned.add('finance');
      else if (!safePinned.contains('health'))
        safePinned.add('health');
      else
        safePinned.add('categories'); // Fallback
    }

    // Construct the 5 items: Home, Pinned 1, Pinned 2, Pinned 3, Categories
    final List<String> navItems = ['home', ...safePinned.take(3), 'categories'];

    // Calculate selected index for NavigationBar
    int selectedIndex = 4; // Default to 'Categories' (Menu)

    final currentBranch = navigationShell.currentIndex;

    // Check if current branch matches any of the visible items
    for (int i = 0; i < navItems.length; i++) {
      final item = navItems[i];
      final branchIndex = branchIndexMap[item] ?? 7;
      if (currentBranch == branchIndex) {
        selectedIndex = i;
        break;
      }
    }

    // If not found (e.g. we are on Settings (8) which is not in nav items),
    // keep selectedIndex as 4 (Menu/Categories) as a fallback highlight.
    // However, if we are on a pinned item that IS in the list, it matched above.

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final item = navItems[index];
          final branchIndex = branchIndexMap[item] ?? 7;
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: navItems.map((item) {
          return NavigationDestination(
            icon: Icon(iconMap[item] ?? Icons.circle_outlined),
            selectedIcon: Icon(selectedIconMap[item] ?? Icons.circle),
            label: _getLabel(context, item, l10n),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(BuildContext context, String item, AppLocalizations l10n) {
    switch (item) {
      case 'home':
        return l10n.homeTitle;
      case 'calendar':
        return l10n.calendarTitle;
      case 'finance':
        return 'Finanças'; // TODO: Localize
      case 'health':
        return 'Saúde';
      case 'education':
        return 'Estudos';
      case 'diet':
        return 'Dieta';
      case 'shopping':
        return 'Mercado';
      case 'categories':
        return 'Menu';
      case 'settings':
        return l10n.settingsTitle;
      default:
        return '';
    }
  }
}
