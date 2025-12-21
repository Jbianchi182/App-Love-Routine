import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/health/domain/models/medication.dart';
import 'package:love_routine_app/features/health/domain/models/medical_appointment.dart';

class MedicationNotifier extends AsyncNotifier<List<Medication>> {
  late Box<Medication> _box;

  @override
  Future<List<Medication>> build() async {
    _box = Hive.box<Medication>('medications');
    return _fetchMedications();
  }

  Future<List<Medication>> _fetchMedications() async {
    return _box.values.toList();
  }

  Future<void> addMedication(Medication medication) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _box.add(medication);
      return _fetchMedications();
    });
  }

  Future<void> deleteMedication(Medication medication) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await medication.delete();
      return _fetchMedications();
    });
  }

  Future<void> markAsTaken(Medication medication) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now();
      medication.takenHistory.add(now);

      if (medication.frequencyHours != null) {
        // Calculate next dose based on this taken time
        medication.nextDose = now.add(
          Duration(hours: medication.frequencyHours!),
        );
      }

      await medication.save();
      return _fetchMedications();
    });
  }
}

final medicationProvider =
    AsyncNotifierProvider<MedicationNotifier, List<Medication>>(() {
      return MedicationNotifier();
    });

class AppointmentNotifier extends AsyncNotifier<List<MedicalAppointment>> {
  late Box<MedicalAppointment> _box;

  @override
  Future<List<MedicalAppointment>> build() async {
    _box = Hive.box<MedicalAppointment>('medical_appointments');
    return _fetchAppointments();
  }

  Future<List<MedicalAppointment>> _fetchAppointments() async {
    final appointments = _box.values.toList();
    appointments.sort((a, b) => a.date.compareTo(b.date));
    return appointments;
  }

  Future<void> addAppointment(MedicalAppointment appointment) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _box.add(appointment);
      return _fetchAppointments();
    });
  }

  Future<void> deleteAppointment(MedicalAppointment appointment) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await appointment.delete();
      return _fetchAppointments();
    });
  }
}

final appointmentProvider =
    AsyncNotifierProvider<AppointmentNotifier, List<MedicalAppointment>>(() {
      return AppointmentNotifier();
    });
