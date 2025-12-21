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
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:love_routine_app/features/diets/domain/enums/diet_tag.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Adapters
  // We need to register adapters for Enums if we didn't use HiveType on them (which we didn't explicitly, but Hive can handle if we annotate them or write adapters.
  // However, for simplicity and since enums are small, we might need to annotate them or let Hive generate.
  // Actually, Hive Generator handles Enums if annotated. I didn't annotate Enums in the models refactor?
  // Checking models... RoutineStatus, RecurrenceType, DietTag seem to be used.
  // If they are not annotated with @HiveType, we will have runtime errors.
  // I should check Enums and annotate them!

  // Assuming generated adapters will be named like RoutineAdapter, etc.
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

  // Open Boxes
  await Hive.openBox<Routine>('routines');
  await Hive.openBox<DietMeal>('diet_meals');
  await Hive.openBox<MedicalAppointment>('medical_appointments');
  await Hive.openBox<Medication>('medications');
  await Hive.openBox<Subject>('subjects');
  // GradeEntry can be in a separate box or same if not accessed directly often.
  // Given relationships, separate box is fine.
  await Hive.openBox<GradeEntry>('grade_entries');
  await Hive.openBox<FinanceTransaction>('transactions');

  runApp(const ProviderScope(child: LoveRoutineApp()));
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
