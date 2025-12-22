import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:love_routine_app/features/finance/domain/models/payment_method.dart';

class AddPaymentMethodDialog extends StatefulWidget {
  final PaymentMethod? paymentMethod;

  const AddPaymentMethodDialog({super.key, this.paymentMethod});

  @override
  State<AddPaymentMethodDialog> createState() => _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<AddPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _limitController;

  late String _selectedType;
  late Color _selectedColor;
  int? _closingDay;
  int? _dueDay;

  final List<String> _types = ['credit', 'debit', 'cash', 'pix', 'other'];
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.black,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.paymentMethod?.name ?? '',
    );
    _limitController = TextEditingController(
      text: widget.paymentMethod?.limit?.toStringAsFixed(2) ?? '',
    );
    _selectedType = widget.paymentMethod?.type ?? 'credit';
    _closingDay = widget.paymentMethod?.closingDay;
    _dueDay = widget.paymentMethod?.dueDay;

    _selectedColor = widget.paymentMethod != null
        ? Color(widget.paymentMethod!.colorValue)
        : Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.paymentMethod == null
            ? 'Novo Método de Pagamento'
            : 'Editar Método',
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
                  labelText: 'Nome do Cartão/Método',
                  hintText: 'Ex: Nubank, Dinheiro',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: _types.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(_translateType(t)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              if (_selectedType == 'credit') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limitController,
                  decoration: const InputDecoration(
                    labelText: 'Limite do Cartão (R\$)',
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Informe o limite';
                    if (double.tryParse(value.replaceAll(',', '.')) == null)
                      return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _closingDay,
                        decoration: const InputDecoration(
                          labelText: 'Fechamento',
                        ),
                        hint: const Text('Dia'),
                        items: List.generate(31, (i) => i + 1).map((day) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text('$day'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _closingDay = val),
                        validator: (val) => val == null ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _dueDay,
                        decoration: const InputDecoration(
                          labelText: 'Vencimento',
                        ),
                        hint: const Text('Dia'),
                        items: List.generate(31, (i) => i + 1).map((day) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text('$day'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _dueDay = val),
                        validator: (val) => val == null ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Cor (para identificação)'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(width: 3, color: Colors.white)
                            : null,
                        boxShadow: [
                          if (_selectedColor == color)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                        ],
                      ),
                      child: _selectedColor == color
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
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

  String _translateType(String type) {
    switch (type) {
      case 'credit':
        return 'Crédito';
      case 'debit':
        return 'Débito';
      case 'cash':
        return 'Dinheiro';
      case 'pix':
        return 'Pix';
      case 'other':
        return 'Outro';
      default:
        return type;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      double? limit;

      if (_selectedType == 'credit') {
        limit = double.tryParse(_limitController.text.replaceAll(',', '.'));
      }

      final method = PaymentMethod(
        id: widget.paymentMethod?.id ?? const Uuid().v4(),
        name: _nameController.text,
        type: _selectedType,
        colorValue: _selectedColor.value,
        limit: limit,
        closingDay: _closingDay,
        dueDay: _dueDay,
      );
      Navigator.pop(context, method);
    }
  }
}
