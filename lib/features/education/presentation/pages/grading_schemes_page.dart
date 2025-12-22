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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome (ex: Padrão Engenharia)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: formulaController,
              decoration: const InputDecoration(
                labelText: 'Fórmula',
                hintText: 'Ex: (N1 * 0.4) + (N2 * 0.6)',
              ),
            ),
          ],
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
