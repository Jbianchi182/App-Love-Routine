import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_preferences_provider.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch preferences for view mode
    final prefsAsync = ref.watch(homePreferencesProvider);
    final isGrid = prefsAsync.asData?.value.isGridView ?? true;
    final l10n = AppLocalizations.of(context)!;

    final categories = [
      _CategoryItem(
        title: l10n.financeTitle,
        icon: Icons.attach_money,
        color: Colors.green,
        route: '/finance',
      ),
      _CategoryItem(
        title: l10n.healthTitle,
        icon: Icons.favorite,
        color: Colors.redAccent,
        route: '/health',
      ),
      _CategoryItem(
        title: l10n.educationTitle,
        icon: Icons.school,
        color: Colors.orange,
        route: '/education',
      ),
      _CategoryItem(
        title: l10n.dietTitle,
        icon: Icons.restaurant_menu,
        color: Colors.teal,
        route: '/diet',
      ),
      _CategoryItem(
        title: l10n.shoppingTitle,
        icon: Icons.shopping_cart,
        color: Colors.purple,
        route: '/shopping',
      ),
      _CategoryItem(
        title: l10n.settingsTitle,
        icon: Icons.settings,
        color: Colors.grey,
        route: '/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuTitle), // Localized Title
        actions: [
          // View Toggle Buttons
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ToggleButtons(
              constraints: const BoxConstraints(minHeight: 32, minWidth: 48),
              borderRadius: BorderRadius.circular(8),
              isSelected: [isGrid, !isGrid],
              onPressed: (index) {
                // If index 0 (Grid) is pressed and !isGrid, toggle.
                // If index 1 (List) is pressed and isGrid, toggle.
                if ((index == 0 && !isGrid) || (index == 1 && isGrid)) {
                  ref.read(homePreferencesProvider.notifier).toggleMenuView();
                }
              },
              children: const [
                Icon(Icons.grid_view, size: 20),
                Icon(Icons.view_list, size: 20),
              ],
            ),
          ),
        ],
      ),
      body: isGrid
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(item: categories[index], isGrid: true);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _CategoryCard(item: categories[index], isGrid: false);
              },
            ),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _CategoryItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final bool isGrid;

  const _CategoryCard({required this.item, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(24),
        child: isGrid
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: item.color.withOpacity(0.1),
                    child: Icon(item.icon, size: 30, color: item.color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: item.color.withOpacity(0.1),
                      child: Icon(item.icon, size: 24, color: item.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
