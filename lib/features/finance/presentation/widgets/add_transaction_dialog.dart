import 'package:flutter/material.dart';
import 'package:love_routine_app/features/finance/domain/models/finance_transaction.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_category.dart';

class AddTransactionDialog extends StatefulWidget {
  final FinanceTransaction? transaction;

  const AddTransactionDialog({super.key, this.transaction});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TransactionType _selectedType;
  late TransactionCategory _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.transaction?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _selectedType = widget.transaction?.type ?? TransactionType.expense;
    _selectedCategory =
        widget.transaction?.category ?? TransactionCategory.food;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.transaction == null ? 'Nova Transação' : 'Editar Transação',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type Toggle
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Receita'),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Despesa'),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe a descrição'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: TransactionCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),
              InputDatePickerFormField(
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDate: _selectedDate,
                onDateSubmitted: (date) => setState(() => _selectedDate = date),
                onDateSaved: (date) => setState(() => _selectedDate = date),
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
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final transaction = FinanceTransaction()
        ..id = widget.transaction?.id
        ..title = _titleController.text
        ..amount = double.parse(_amountController.text)
        ..type = _selectedType
        ..category = _selectedCategory
        ..date = _selectedDate;

      Navigator.pop(context, transaction);
    }
  }
}
