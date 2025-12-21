import 'package:flutter/material.dart';
import 'package:love_routine_app/features/health/domain/models/medical_appointment.dart';
import 'package:intl/intl.dart';

class AppointmentDialog extends StatefulWidget {
  const AppointmentDialog({super.key});

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _patientController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Consulta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Especialidade / Médico'),
                validator: (value) => value!.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _patientController,
                decoration: const InputDecoration(labelText: 'Nome do Paciente'),
                validator: (value) => value!.isEmpty ? 'Informe o paciente' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Local (Opcional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Data'),
                        child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Horário'),
                        child: Text(_time.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final appointmentDate = DateTime(
                _date.year,
                _date.month,
                _date.day,
                _time.hour,
                _time.minute,
              );

              final appointment = MedicalAppointment()
                ..title = _titleController.text
                ..patientName = _patientController.text
                ..location = _locationController.text
                ..date = appointmentDate;

              Navigator.pop(context, appointment);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
