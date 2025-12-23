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
    'finance':
        1, // Shifted indices? No, StatefulShellRoute branches are indexed by order in the list.
    // If I removed branch 1 (calendar), then finance is now 1.
    // I need to update ALL indices.
    'health': 2,
    'education': 3,
    'diet': 4,
    'shopping': 5,
    'categories': 6,
    'settings': 7,
  };

  static const Map<String, IconData> iconMap = {
    'home': Icons.home_outlined,
    //    'calendar': Icons.calendar_month_outlined, // Removed
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
    //    'calendar': Icons.calendar_month, // Removed
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
    final rawPinned = prefs.pinnedModules.isNotEmpty
        ? prefs.pinnedModules
        : ['finance', 'health', 'education'];

    // Force remove 'calendar' if it exists in saved preferences
    final pinned = rawPinned.where((m) => m != 'calendar').toList();

    // Ensure we have exactly 3 pinned items, pad with defaults if needed
    final safePinned = List<String>.from(pinned);
    while (safePinned.length < 3) {
      if (!safePinned.contains('finance'))
        safePinned.add('finance');
      else if (!safePinned.contains('health'))
        safePinned.add('health');
      else if (!safePinned.contains('education'))
        safePinned.add('education');
      else if (!safePinned.contains('diet'))
        safePinned.add('diet');
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
