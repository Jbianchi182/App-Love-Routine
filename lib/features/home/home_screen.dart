import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/home/presentation/providers/home_provider.dart';
import 'package:love_routine_app/features/home/presentation/widgets/financial_summary_widget.dart';
import 'package:love_routine_app/features/home/presentation/widgets/home_calendar_widget.dart';
import 'package:love_routine_app/features/home/presentation/widgets/upcoming_events_list_widget.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider to ensure state is initialized
    final homeState = ref.watch(homeProvider);
    final l10n = AppLocalizations.of(context)!;

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
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 20),
          ),
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
              FinancialSummaryWidget(
                income: homeState.income,
                expense: homeState.expense,
              ),
              const SizedBox(height: 16),
              const HomeCalendarWidget(),
              const SizedBox(height: 16),
              const UpcomingEventsListWidget(),
              const SizedBox(height: 80), // Bottom padding for FAB or Nav Bar
            ],
          ),
        ),
      ),
    );
  }
}
