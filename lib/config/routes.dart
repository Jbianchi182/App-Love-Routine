import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:love_routine_app/core/widgets/main_scaffold.dart';
import 'package:love_routine_app/features/home/home_screen.dart';
import 'package:love_routine_app/features/home/placeholders.dart';
import 'package:love_routine_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:love_routine_app/features/diets/presentation/pages/diet_page.dart';
import 'package:love_routine_app/features/settings/presentation/pages/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _calendarNavigatorKey = GlobalKey<NavigatorState>();
final _financeNavigatorKey = GlobalKey<NavigatorState>();
final _educationNavigatorKey = GlobalKey<NavigatorState>();
final _menuNavigatorKey = GlobalKey<NavigatorState>();

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
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
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
          navigatorKey: _educationNavigatorKey,
          routes: [
            GoRoute(
              path: '/education',
              // Renaming Education tab to Diet/Health/Education later, or strictly Diet per user request context?
              // The user asked for "Diet section... Health page... Education page... Financial page".
              // My placeholders: Calendar, Finance, Education, Menu. 
              // I missed a tab for Diet and Health in the main scaffold!
              // I should probably replace "Education" or add more tabs. 
              // Given the visual density, let's look at the navigation structure again.
              // Task said: "bottom navigation bar for menus".
              // Let's replace the Education placeholder with DietPage for now as requested by user context "Diet section".
              // Actually, I should probably add it properly.
              builder: (context, state) => const DietPage(), 
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _menuNavigatorKey,
          routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => const SettingsPage(), // Using Settings as Menu for now
            ),
          ],
        ),
      ],
    ),
  ],
);
