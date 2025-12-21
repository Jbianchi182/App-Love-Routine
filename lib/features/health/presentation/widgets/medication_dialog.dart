import 'package:flutter/material.dart';
import 'package:love_routine_app/features/health/domain/models/medication.dart';
import 'package:intl/intl.dart';

class MedicationDialog extends StatefulWidget {
  final Medication? medication;

  const MedicationDialog({super.key, this.medication});

  @override
  State<MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _durationController;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;
    _nameController = TextEditingController(text: med?.name);
    _dosageController = TextEditingController(text: med?.dosage);
    _frequencyController = TextEditingController(
      text: med?.frequencyHours?.toString(),
    );
    _durationController = TextEditingController(
      text: med?.durationDays?.toString(),
    );
    _startDate = med?.startDate ?? DateTime.now();
    _endDate = med?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _calculateEndDate() {
    final days = int.tryParse(_durationController.text);
    if (days != null) {
      setState(() {
        _endDate = _startDate.add(Duration(days: days));
      });
    } else {
      setState(() {
        _endDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.medication == null ? 'Novo Medicamento' : 'Editar Medicamento',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Medicamento',
                ),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosagem (ex: 500mg)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Informe a dosagem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _frequencyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Frequência (horas)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Informe a frequência' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duração (dias) - Opcional',
                ),
                onChanged: (_) => _calculateEndDate(),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Início do tratamento',
                ),
                child: Text(DateFormat('dd/MM/yyyy HH:mm').format(_startDate)),
              ),
              if (_endDate != null) ...[
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fim do tratamento (Calculado)',
                  ),
                  child: Text(DateFormat('dd/MM/yyyy HH:mm').format(_endDate!)),
                ),
              ],
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
            if (_formKey.currentState!.validate()) {
              final medication = widget.medication ?? Medication();
              medication
                ..name = _nameController.text
                ..dosage = _dosageController.text
                ..frequencyHours = int.tryParse(_frequencyController.text) ?? 8
                ..durationDays = int.tryParse(_durationController.text)
                ..startDate = _startDate
                ..endDate = _endDate;

              // Only set nextDose if new, otherwise preserve or update logic?
              // If editing, maybe keep nextDose unless frequency changed?
              // For simplicity, if new:
              if (widget.medication == null) {
                medication.nextDose = _startDate;
              }

              Navigator.pop(context, medication);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
