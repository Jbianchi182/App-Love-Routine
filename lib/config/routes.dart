import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/core/widgets/main_scaffold.dart';
import 'package:love_routine_app/features/home/home_screen.dart';
import 'package:love_routine_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:love_routine_app/features/health/presentation/pages/health_page.dart';
import 'package:love_routine_app/features/education/presentation/pages/education_page.dart';
import 'package:love_routine_app/features/settings/presentation/pages/settings_page.dart';
import 'package:love_routine_app/features/finance/presentation/pages/finance_page.dart';
import 'package:love_routine_app/features/diets/presentation/pages/diet_page.dart';
import 'package:love_routine_app/features/shopping/presentation/pages/shopping_list_page.dart';
import 'package:love_routine_app/features/shopping/presentation/pages/shopping_history_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _calendarNavigatorKey = GlobalKey<NavigatorState>();
final _healthNavigatorKey = GlobalKey<NavigatorState>();
final _menuNavigatorKey = GlobalKey<NavigatorState>();
final _financeNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _calendarNavigatorKey,
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _financeNavigatorKey,
          routes: [
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinancePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _healthNavigatorKey,
          routes: [
            GoRoute(
              path: '/health',
              builder: (context, state) => const HealthPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _menuNavigatorKey,
          routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'education',
                  builder: (context, state) => const EducationPage(),
                ),
                GoRoute(
                  path: 'diet',
                  builder: (context, state) => const DietPage(),
                ),
                GoRoute(
                  path: 'shopping',
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
          ],
        ),
      ],
    ),
  ],
);
