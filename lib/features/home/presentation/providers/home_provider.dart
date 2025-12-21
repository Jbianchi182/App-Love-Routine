import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final double income;
  final double expense;
  
  // Mock events for now
  final List<String> upcomingEvents;

  HomeState({
    required this.selectedDate,
    required this.focusedDate,
    this.income = 0.0,
    this.expense = 0.0,
    this.upcomingEvents = const [],
  });

  HomeState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDate,
    double? income,
    double? expense,
    List<String>? upcomingEvents,
  }) {
    return HomeState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final now = DateTime.now();
    return HomeState(
      selectedDate: now,
      focusedDate: now,
      income: 5000.0, // Mock data
      expense: 3200.50, // Mock data
      upcomingEvents: [
        'Dentist Appointment - 14:00',
        'Project Meeting - 16:30',
        'Dinner with Sarah - 20:00',
      ],
    );
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(
      selectedDate: selectedDay,
      focusedDate: focusedDay,
    );
  }

  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDate: focusedDay);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});
