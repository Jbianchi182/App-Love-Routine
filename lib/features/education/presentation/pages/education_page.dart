import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';
import 'package:love_routine_app/features/education/presentation/providers/education_provider.dart';
import 'package:love_routine_app/features/education/presentation/widgets/subject_dialog.dart';
import 'package:intl/intl.dart';

class EducationPage extends ConsumerWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(educationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Educação')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return const Center(child: Text('Nenhuma matéria cadastrada.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectCard(context, ref, subject);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) {
    final grades = subject.grades.toList();
    final average = _calculateAverage(grades);
    final passing = subject.passingScore ?? 6.0;
    final isPassing = average >= passing;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isPassing
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Text(
            average.toStringAsFixed(1),
            style: TextStyle(
              color: isPassing ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subject.teacherName ?? 'Sem professor'),
        children: [
          if (grades.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Nenhuma nota lançada.'),
            )
          else
            ...grades.map(
              (grade) => ListTile(
                dense: true,
                title: Text(grade.name),
                subtitle: Text(DateFormat('dd/MM').format(grade.date)),
                trailing: Text(
                  grade.score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () => _showAddGradeDialog(context, ref, subject),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Nota'),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAverage(List<GradeEntry> grades) {
    if (grades.isEmpty) return 0.0;
    // Simple average for now. Weighted average logic to be added.
    double sum = 0;
    for (var g in grades) {
      sum += g.score;
    }
    return sum / grades.length;
  }

  Future<void> _showSubjectDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Subject>(
      context: context,
      builder: (_) => const SubjectDialog(),
    );
    if (result != null) {
      ref.read(educationProvider.notifier).addSubject(result);
    }
  }

  Future<void> _showAddGradeDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final scoreController = TextEditingController();
    final nameController = TextEditingController();

    final entry = await showDialog<GradeEntry>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lançar Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Descrição (ex: Prova 1)',
              ),
            ),
            TextField(
              controller: scoreController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Nota obtenuida'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final score = double.tryParse(scoreController.text);
              if (score != null) {
                Navigator.pop(
                  context,
                  GradeEntry()
                    ..name = nameController.text.isEmpty
                        ? 'Nota'
                        : nameController.text
                    ..score = score
                    ..weight = 1.0
                    ..date = DateTime.now(),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (entry != null) {
      ref.read(educationProvider.notifier).addGrade(subject.key, entry);
    }
  }
}
