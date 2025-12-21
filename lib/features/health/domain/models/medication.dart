import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 4)
class Medication extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String dosage; // e.g., "500mg", "1 pill"

  // Frequency in hours (e.g., every 8 hours)
  @HiveField(3)
  int? frequencyHours;

  @HiveField(4)
  late DateTime startDate;

  @HiveField(5)
  DateTime? endDate;

  // Next scheduled dose time
  @HiveField(6)
  late DateTime nextDose;
}
