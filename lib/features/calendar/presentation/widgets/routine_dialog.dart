import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/calendar/domain/models/routine.dart';
import 'package:love_routine_app/features/calendar/domain/enums/recurrence_type.dart';
import 'package:love_routine_app/features/calendar/domain/enums/routine_status.dart';
import 'package:love_routine_app/features/calendar/presentation/widgets/card_style_selector.dart';
import 'package:love_routine_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class RoutineDialog extends ConsumerStatefulWidget {
  final Routine? routine;
  final DateTime? initialDate;

  const RoutineDialog({super.key, this.routine, this.initialDate});

  @override
  ConsumerState<RoutineDialog> createState() => _RoutineDialogState();
}

class _RoutineDialogState extends ConsumerState<RoutineDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _time;
  late RecurrenceType _recurrence;
  String? _cardStyle;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;
    _titleController = TextEditingController(text: routine?.title);
    _descriptionController = TextEditingController(text: routine?.description);
    _startDate = routine?.startDate ?? widget.initialDate ?? DateTime.now();
    _time = routine?.time ?? DateTime.now();
    _recurrence = routine?.recurrence ?? RecurrenceType.none;
    _cardStyle = routine?.cardStyle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final timeOfDay = TimeOfDay.fromDateTime(_time);
    final picked = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (picked != null) {
      setState(() {
        _time = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.routine == null ? l10n.newRoutine : l10n.editRoutine),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.titleLabel),
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.titleLabel : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: l10n.descriptionLabel),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.startDateLabel,
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: l10n.timeLabel),
                        child: Text(DateFormat('HH:mm').format(_time)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrence,
                decoration: InputDecoration(labelText: l10n.recurrenceLabel),
                items: RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getRecurrenceLabel(type, l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _recurrence = value);
                },
              ),
              const SizedBox(height: 16),
              CardStyleSelector(
                key: ValueKey(_cardStyle),
                selectedStyle: _cardStyle,
                onStyleSelected: (style) {
                  setState(() => _cardStyle = style);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(onPressed: _saveRoutine, child: Text(l10n.saveButton)),
      ],
    );
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      final routine = widget.routine ?? Routine()
        ..status = RoutineStatus.pending
        ..history = [];

      routine
        ..title = _titleController.text
        ..description = _descriptionController.text
        ..startDate = _startDate
        ..time = _time
        ..recurrence = _recurrence
        ..cardStyle = _cardStyle;

      Navigator.pop(context, routine);
    }
  }

  String _getRecurrenceLabel(RecurrenceType type, AppLocalizations l10n) {
    switch (type) {
      case RecurrenceType.none:
        return l10n.recurrenceNone;
      case RecurrenceType.daily:
        return l10n.recurrenceDaily;
      case RecurrenceType.weekly:
        return l10n.recurrenceWeekly;
      case RecurrenceType.monthly:
        return l10n.recurrenceMonthly;
      case RecurrenceType.custom:
        return l10n.recurrenceCustom;
    }
  }
}
