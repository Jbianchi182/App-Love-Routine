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
  late TextEditingController _durationController;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isContinuous;
  int? _selectedFrequency;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;
    _nameController = TextEditingController(text: med?.name);
    _dosageController = TextEditingController(text: med?.dosage);
    _durationController = TextEditingController(
      text: med?.durationDays?.toString(),
    );
    _startDate = med?.startDate ?? DateTime.now();
    _endDate = med?.endDate;
    _isContinuous = med?.isContinuous ?? false;
    _selectedFrequency = med?.frequencyHours ?? 8;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _calculateEndDate() {
    if (_isContinuous) {
      setState(() => _endDate = null);
      return;
    }
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

  Future<void> _selectStartDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );

      if (pickedTime != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _calculateEndDate();
        });
      }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Medicamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosagem (ex: 500mg, 1 gota)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Informe a dosagem' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Frequência',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [4, 6, 8, 12, 24].map((h) {
                  final isSelected = _selectedFrequency == h;
                  return ChoiceChip(
                    label: Text(h == 24 ? '1x ao dia' : 'Cada ${h}h'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFrequency = h);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Duração do Tratamento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: const Text('Uso Contínuo'),
                value: _isContinuous,
                onChanged: (val) {
                  setState(() {
                    _isContinuous = val ?? false;
                    if (_isContinuous) {
                      _durationController.clear();
                      _endDate = null;
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (!_isContinuous)
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duração (dias)',
                    border: OutlineInputBorder(),
                    helperText: 'Deixe vazio para duração indefinida',
                  ),
                  onChanged: (_) => _calculateEndDate(),
                ),
              const SizedBox(height: 24),
              const Text(
                'Início do Tratamento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectStartDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(_startDate),
                  ),
                ),
              ),
              if (_endDate != null && !_isContinuous) ...[
                const SizedBox(height: 16),
                Text(
                  'Término previsto: ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
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
                ..frequencyHours = _selectedFrequency ?? 8
                ..durationDays = int.tryParse(_durationController.text)
                ..startDate = _startDate
                ..endDate = _endDate
                ..isContinuous = _isContinuous;

              // If it's new or the startDate was changed to the future
              if (widget.medication == null || _startDate.isAfter(DateTime.now())) {
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
