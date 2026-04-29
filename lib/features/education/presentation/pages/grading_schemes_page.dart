import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/education/domain/models/grading_scheme.dart';
import 'package:love_routine_app/features/education/presentation/providers/grading_scheme_provider.dart';

class GradingSchemesPage extends ConsumerWidget {
  const GradingSchemesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemes = ref.watch(gradingSchemeProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Fórmulas de Avaliação')),
      body: schemes.isEmpty
          ? const Center(
              child: Text('Nenhuma fórmula criada. \nToque em + para criar.'),
            )
          : ListView.builder(
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return ListTile(
                  title: Text(scheme.name),
                  subtitle: Text(scheme.formula),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref
                          .read(gradingSchemeProvider.notifier)
                          .deleteScheme(scheme);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final formulaController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Fórmula'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Presets de Universidades',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _PresetChip(
                    label: 'USP / FATEC (Simples)',
                    formula: '(P1 + P2) / 2',
                    nameController: nameController,
                    formulaController: formulaController,
                  ),
                  _PresetChip(
                    label: 'USP / Unicamp (Ponderada)',
                    formula: '(P1 + P2 * 2) / 3',
                    nameController: nameController,
                    formulaController: formulaController,
                  ),
                  _PresetChip(
                    label: 'UFRJ / UFSC / UnB',
                    formula: '(P1 + P2 + P3) / 3',
                    nameController: nameController,
                    formulaController: formulaController,
                  ),
                  _PresetChip(
                    label: 'UFMG (100 pts)',
                    formula: 'P1 + P2 + P3',
                    nameController: nameController,
                    formulaController: formulaController,
                  ),
                  _PresetChip(
                    label: 'USCS',
                    formula: '(P1 + ((P2 + Atividades) / 2)) / 2',
                    nameController: nameController,
                    formulaController: formulaController,
                  ),
                  _PresetChip(
                    label: 'Padrão c/ Atividades',
                    formula: '(P1 * 4 + P2 * 4 + Atividades * 2) / 10',
                    nameController: nameController,
                    formulaController: formulaController,
                  ),
                ],
              ),
              const Divider(height: 32),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Fórmula',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: formulaController,
                decoration: const InputDecoration(
                  labelText: 'Fórmula Matemática',
                  hintText: 'Ex: (P1 + P2) / 2',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  formulaController.text.isNotEmpty) {
                final scheme = GradingScheme()
                  ..name = nameController.text
                  ..formula = formulaController.text;
                ref.read(gradingSchemeProvider.notifier).addScheme(scheme);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final String formula;
  final TextEditingController nameController;
  final TextEditingController formulaController;

  const _PresetChip({
    required this.label,
    required this.formula,
    required this.nameController,
    required this.formulaController,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        nameController.text = label;
        formulaController.text = formula;
      },
    );
  }
}
