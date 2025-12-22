import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/config/routes.dart';
import 'package:love_routine_app/config/theme.dart';
import 'package:love_routine_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/diets/domain/models/diet_meal.dart';
import 'package:love_routine_app/features/health/domain/models/medical_appointment.dart';
import 'package:love_routine_app/features/health/domain/models/medication.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';
import 'package:love_routine_app/features/education/domain/models/grading_scheme.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:love_routine_app/features/diets/domain/enums/diet_tag.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_category.dart';
import 'package:love_routine_app/features/home/domain/models/home_preferences.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_item.dart';
import 'package:love_routine_app/features/shopping/domain/models/shopping_trip.dart';
import 'package:love_routine_app/features/finance/domain/models/payment_method.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(RoutineAdapter());
    Hive.registerAdapter(RoutineHistoryEntryAdapter());
    Hive.registerAdapter(DietMealAdapter());
    Hive.registerAdapter(MedicalAppointmentAdapter());
    Hive.registerAdapter(MedicationAdapter());
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(GradeEntryAdapter());

    // Register Enum Adapters
    Hive.registerAdapter(RoutineStatusAdapter());
    Hive.registerAdapter(RecurrenceTypeAdapter());
    Hive.registerAdapter(DietTagAdapter());
    Hive.registerAdapter(FinanceTransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionCategoryAdapter());

    Hive.registerAdapter(GradingSchemeAdapter());
    Hive.registerAdapter(HomePreferencesAdapter());
    Hive.registerAdapter(ShoppingItemAdapter());
    Hive.registerAdapter(ShoppingTripAdapter());
    Hive.registerAdapter(PaymentMethodAdapter());

    // Open Boxes
    await Hive.openBox<Routine>('routines');
    await Hive.openBox<DietMeal>('diet_meals');
    await Hive.openBox<MedicalAppointment>('medical_appointments');
    await Hive.openBox<Medication>('medications');
    await Hive.openBox<Subject>('subjects');
    await Hive.openBox<GradeEntry>('grade_entries');
    await Hive.openBox<FinanceTransaction>('transactions');
    await Hive.openBox<GradingScheme>('grading_schemes');
    await Hive.openBox<HomePreferences>('home_preferences');
    await Hive.openBox<ShoppingItem>('shopping_items');
    await Hive.openBox<ShoppingTrip>('shopping_history');
    await Hive.openBox<PaymentMethod>('payment_methods');

    runApp(const ProviderScope(child: LoveRoutineApp()));
  } catch (e, stack) {
    debugPrint('Startup Error: $e');
    debugPrint(stack.toString());
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao iniciar o App:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(e.toString()),
                const SizedBox(height: 16),
                const Text('Stack Trace:'),
                SelectableText(stack.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoveRoutineApp extends ConsumerWidget {
  const LoveRoutineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Love Routine',
      theme: AppTheme.getTheme(settings.themeType),
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
