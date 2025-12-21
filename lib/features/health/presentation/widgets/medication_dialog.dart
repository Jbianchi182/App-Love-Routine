import 'package:flutter/material.dart';
import 'package:love_routine_app/features/health/domain/models/medication.dart';
import 'package:intl/intl.dart';

class MedicationDialog extends StatelessWidget {
  const MedicationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController(); // hours
    DateTime startDate = DateTime.now();

    return AlertDialog(
      title: const Text('Novo Medicamento'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Medicamento',
                ),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosagem (ex: 500mg)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Informe a dosagem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: frequencyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Frequência (horas)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Informe a frequência' : null,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Início do tratamento',
                ),
                child: Text(DateFormat('dd/MM/yyyy HH:mm').format(startDate)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final medication = Medication()
                ..name = nameController.text
                ..dosage = dosageController.text
                ..frequencyHours = int.tryParse(frequencyController.text) ?? 8
                ..startDate = startDate
                ..nextDose =
                    startDate; // logic to calculate real next dose would be here

              Navigator.pop(context, medication);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
