import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/diets/domain/models/fasting_routine.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:table_calendar/table_calendar.dart';

class FastingDialog extends ConsumerStatefulWidget {
  final FastingRoutine? routine;

  const FastingDialog({super.key, this.routine});

  @override
  ConsumerState<FastingDialog> createState() => _FastingDialogState();
}

class _FastingDialogState extends ConsumerState<FastingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int _fastingHours = 16;
  late DateTime _startTime;

  RecurrenceType _recurrence = RecurrenceType.daily;
  Set<int> _selectedDays = {};
  Set<int> _selectedMonthDays = {};
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;
    _nameController = TextEditingController(text: routine?.name ?? 'Jejum Intermitente');
    _fastingHours = routine?.fastingHours ?? 16;
    _startTime = routine?.startTime ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 0); // Default 20:00
    
    if (routine != null) {
      _isActive = routine.isActive;
      _recurrence = routine.recurrence;
      if (routine.customDaysOfWeek != null) {
        _selectedDays.addAll(routine.customDaysOfWeek!);
      }
      if (routine.customDaysOfMonth != null) {
        _selectedMonthDays.addAll(routine.customDaysOfMonth!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final timeOfDay = TimeOfDay.fromDateTime(_startTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endTime = _startTime.add(Duration(hours: _fastingHours));

    return AlertDialog(
      title: Text(widget.routine == null ? 'Nova Rotina de Jejum' : 'Editar Jejum'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _fastingHours,
                decoration: const InputDecoration(labelText: 'Duração do Jejum'),
                items: [12, 14, 16, 18, 20, 24].map((hours) {
                  return DropdownMenuItem(
                    value: hours,
                    child: Text('$hours horas (${24 - hours}h alimentação)'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _fastingHours = val);
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Horário de Início',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo da Janela:',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('🔴 Jejum: ${_formatTime(_startTime)} às ${_formatTime(endTime)}'),
                    Text('🟢 Alimentação: ${_formatTime(endTime)} às ${_formatTime(_startTime)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrence,
                decoration: const InputDecoration(labelText: 'Recorrência'),
                items: const [
                  DropdownMenuItem(value: RecurrenceType.daily, child: Text('Diariamente')),
                  DropdownMenuItem(value: RecurrenceType.weekly, child: Text('Semanalmente')),
                  DropdownMenuItem(value: RecurrenceType.monthly, child: Text('Mensalmente (Dias)')),
                  DropdownMenuItem(value: RecurrenceType.custom, child: Text('Personalizado')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _recurrence = val);
                },
              ),
              if (_recurrence == RecurrenceType.monthly) ...[
                const SizedBox(height: 8),
                TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  currentDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  headerVisible: true,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                  ),
                  selectedDayPredicate: (day) => _selectedMonthDays.contains(day.day),
                  onDaySelected: (selectedDay, _) {
                    setState(() {
                      if (_selectedMonthDays.contains(selectedDay.day)) {
                        _selectedMonthDays.remove(selectedDay.day);
                      } else {
                        _selectedMonthDays.add(selectedDay.day);
                      }
                    });
                  },
                ),
              ],
              if (_recurrence == RecurrenceType.custom) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: List.generate(7, (index) {
                    final dayIndex = index + 1;
                    return FilterChip(
                      label: Text(['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'][index]),
                      selected: _selectedDays.contains(dayIndex),
                      onSelected: (selected) {
                        setState(() {
                          selected ? _selectedDays.add(dayIndex) : _selectedDays.remove(dayIndex);
                        });
                      },
                    );
                  }),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Ativar Rotina'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_recurrence == RecurrenceType.custom && _selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione os dias da semana.')));
        return;
      }
      if (_recurrence == RecurrenceType.monthly && _selectedMonthDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione os dias do mês.')));
        return;
      }

      final routine = widget.routine ?? FastingRoutine();
      routine
        ..name = _nameController.text
        ..fastingHours = _fastingHours
        ..startTime = _startTime
        ..isActive = _isActive
        ..recurrence = _recurrence
        ..customDaysOfWeek = _recurrence == RecurrenceType.custom ? _selectedDays.toList() : null
        ..customDaysOfMonth = _recurrence == RecurrenceType.monthly ? _selectedMonthDays.toList() : null;

      if (widget.routine == null) {
         routine.startDate = DateTime.now();
      }

      Navigator.pop(context, routine);
    }
  }
}
