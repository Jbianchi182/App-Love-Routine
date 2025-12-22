import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_provider.dart';
import 'package:love_routine_app/features/home/presentation/widgets/financial_summary_widget.dart';
import 'package:love_routine_app/features/home/presentation/widgets/home_calendar_widget.dart';
import 'package:love_routine_app/features/home/presentation/widgets/upcoming_events_list_widget.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_preferences_provider.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider to ensure state is initialized
    ref.watch(homeProvider); // Keep watching homeProvider for finance data
    final prefsAsync = ref.watch(homePreferencesProvider);
    final homeState = ref.read(homeProvider); // Read for finance widgets
    final l10n = AppLocalizations.of(context)!;

    final prefs =
        prefsAsync.asData?.value ?? HomePreferences(); // Default if loading

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 20)),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ...prefs.sectionOrder.map((section) {
                switch (section) {
                  case 'finance':
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => context.go('/finance'),
                        child: FinancialSummaryWidget(
                          income: homeState.income,
                          expense: homeState.expense,
                        ),
                      ),
                    );
                  case 'calendar':
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: HomeCalendarWidget(),
                    );
                  case 'upcoming':
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: UpcomingEventsListWidget(
                        daysToShow: prefs.upcomingDaysRange,
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              }),
              const SizedBox(height: 80), // Bottom padding for FAB or Nav Bar
            ],
          ),
        ),
      ),
    );
  }
}
