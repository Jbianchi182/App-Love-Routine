import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/core/widgets/main_scaffold.dart';
import 'package:love_routine_app/features/home/home_screen.dart';

import 'package:love_routine_app/features/health/presentation/pages/health_page.dart';
import 'package:love_routine_app/features/education/presentation/pages/education_page.dart';
import 'package:love_routine_app/features/settings/presentation/pages/settings_page.dart';
import 'package:love_routine_app/features/finance/presentation/pages/finance_page.dart';
import 'package:love_routine_app/features/diets/presentation/pages/diet_page.dart';
import 'package:love_routine_app/features/shopping/presentation/pages/shopping_list_page.dart';
import 'package:love_routine_app/features/shopping/presentation/pages/shopping_history_page.dart';
import 'package:love_routine_app/features/menu/presentation/pages/categories_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
// Define keys for all branches
final _homeNavigatorKey = GlobalKey<NavigatorState>();

final _financeNavigatorKey = GlobalKey<NavigatorState>();
final _healthNavigatorKey = GlobalKey<NavigatorState>();
final _educationNavigatorKey = GlobalKey<NavigatorState>();
final _dietNavigatorKey = GlobalKey<NavigatorState>();
final _shoppingNavigatorKey = GlobalKey<NavigatorState>();
final _categoriesNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 0. Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),

        // 2. Finance
        StatefulShellBranch(
          navigatorKey: _financeNavigatorKey,
          routes: [
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinancePage(),
            ),
          ],
        ),
        // 3. Health
        StatefulShellBranch(
          navigatorKey: _healthNavigatorKey,
          routes: [
            GoRoute(
              path: '/health',
              builder: (context, state) => const HealthPage(),
            ),
          ],
        ),
        // 4. Education
        StatefulShellBranch(
          navigatorKey: _educationNavigatorKey,
          routes: [
            GoRoute(
              path: '/education',
              builder: (context, state) => const EducationPage(),
            ),
          ],
        ),
        // 5. Diet
        StatefulShellBranch(
          navigatorKey: _dietNavigatorKey,
          routes: [
            GoRoute(
              path: '/diet',
              builder: (context, state) => const DietPage(),
            ),
          ],
        ),
        // 6. Shopping
        StatefulShellBranch(
          navigatorKey: _shoppingNavigatorKey,
          routes: [
            GoRoute(
              path: '/shopping',
              builder: (context, state) => const ShoppingListPage(),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const ShoppingHistoryPage(),
                ),
              ],
            ),
          ],
        ),
        // 7. Categories (Menu)
        StatefulShellBranch(
          navigatorKey: _categoriesNavigatorKey,
          routes: [
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesPage(),
              // Note: Sub-routes here are removed because they are now top-level branches.
              // Navigation from CategoriesPage will use context.go('/finance') etc.
            ),
          ],
        ),
        // 8. Settings
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
