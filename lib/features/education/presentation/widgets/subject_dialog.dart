import 'package:flutter/material.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';

class SubjectDialog extends StatelessWidget {
  const SubjectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final teacherController = TextEditingController();
    final passingScoreController = TextEditingController(text: '6.0');
    final formulaController = TextEditingController();

    return AlertDialog(
      title: const Text('Nova Matéria'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome da Matéria'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: teacherController,
                decoration: const InputDecoration(
                  labelText: 'Professor (Opcional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passingScoreController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Média para passar',
                ),
                validator: (value) =>
                    double.tryParse(value ?? '') == null ? 'Inválido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: formulaController,
                decoration: const InputDecoration(
                  labelText: 'Fórmula (Opcional)',
                  hintText: 'Ex: (N1 + N2) / 2',
                ),
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
              final subject = Subject()
                ..name = nameController.text
                ..teacherName = teacherController.text
                ..passingScore = double.parse(passingScoreController.text)
                ..gradingFormula = formulaController.text.isEmpty
                    ? null
                    : formulaController.text
                ..maxScore = 10.0; // Defaulting to 0-10 scale

              Navigator.pop(context, subject);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
