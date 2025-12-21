import 'package:hive/hive.dart';

part 'medical_appointment.g.dart';

@HiveType(typeId: 3)
class MedicalAppointment extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String title; // Doctor or Specialty

  @HiveField(2)
  String? description;

  @HiveField(3)
  late String patientName;

  @HiveField(4)
  String? location;

  @HiveField(5)
  late DateTime date;
}
