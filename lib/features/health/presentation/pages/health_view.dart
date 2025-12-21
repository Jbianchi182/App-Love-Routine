import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/health/domain/models/medication.dart';
import 'package:love_routine_app/features/health/domain/models/medical_appointment.dart';
import 'package:love_routine_app/features/health/presentation/providers/health_provider.dart';
import 'package:love_routine_app/features/health/presentation/widgets/medication_dialog.dart';
import 'package:love_routine_app/features/health/presentation/widgets/appointment_dialog.dart';
import 'package:intl/intl.dart';

class HealthView extends ConsumerWidget {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationProvider);
    final appointmentsAsync = ref.watch(appointmentProvider);
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_medication',
            onPressed: () => _showMedicationDialog(context, ref),
            child: const Icon(Icons.medication),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_appointment',
            onPressed: () => _showAppointmentDialog(context, ref),
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Medicamentos',
              Icons.medication_liquid,
            ),
            const SizedBox(height: 8),
            medicationsAsync.when(
              data: (meds) => meds.isEmpty
                  ? const Text('Nenhum medicamento cadastrado.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meds.length,
                      itemBuilder: (context, index) {
                        final med = meds[index];
                        return Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.local_pharmacy),
                                title: Text(med.name),
                                subtitle: Text(
                                  '${med.dosage} • A cada ${med.frequencyHours}h',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showMedicationDialog(
                                        context,
                                        ref,
                                        medication: med,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => ref
                                          .read(medicationProvider.notifier)
                                          .deleteMedication(med),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Próxima dose: ${DateFormat('dd/MM HH:mm').format(med.nextDose)}',
                                      style: TextStyle(
                                        color:
                                            med.nextDose.isBefore(
                                              DateTime.now(),
                                            )
                                            ? Colors.red
                                            : null,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () {
                                        ref
                                            .read(medicationProvider.notifier)
                                            .markAsTaken(med);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Medicamento marcado como tomado!',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Tomar'),
                                      style: FilledButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Consultas', Icons.medical_services),
            const SizedBox(height: 8),
            appointmentsAsync.when(
              data: (appts) => appts.isEmpty
                  ? const Text('Nenhuma consulta agendada.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appts.length,
                      itemBuilder: (context, index) {
                        final appt = appts[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.event),
                            title: Text(appt.title),
                            subtitle: Text(
                              '${DateFormat('dd/MM HH:mm').format(appt.date)}\n${appt.patientName}${appt.location != null ? ' • ${appt.location}' : ''}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => ref
                                  .read(appointmentProvider.notifier)
                                  .deleteAppointment(appt),
                            ),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
            ),
            const SizedBox(height: 80), // Fab space
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _showMedicationDialog(
    BuildContext context,
    WidgetRef ref, {
    Medication? medication,
  }) async {
    final result = await showDialog<Medication>(
      context: context,
      builder: (_) => MedicationDialog(medication: medication),
    );

    if (result != null) {
      if (result.isInBox) {
        await result.save();
        // Force refresh
        ref.invalidate(medicationProvider);
      } else {
        ref.read(medicationProvider.notifier).addMedication(result);
      }
    }
  }

  Future<void> _showAppointmentDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<MedicalAppointment>(
      context: context,
      builder: (_) => const AppointmentDialog(),
    );
    if (result != null) {
      ref.read(appointmentProvider.notifier).addAppointment(result);
    }
  }
}
