// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/main.dart';
import 'package:love_routine_app/features/home/presentation/widgets/financial_summary_widget.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LoveRoutineApp()));
    await tester.pumpAndSettle();

    // Verify that our app starts and shows the Home Screen.
    expect(find.byType(FinancialSummaryWidget), findsOneWidget);
  });
}
