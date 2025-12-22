import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';
import 'package:love_routine_app/features/education/presentation/providers/education_provider.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:love_routine_app/features/education/presentation/providers/grading_scheme_provider.dart';

class SubjectDetailsPage extends ConsumerStatefulWidget {
  final Subject subject;

  const SubjectDetailsPage({super.key, required this.subject});

  @override
  ConsumerState<SubjectDetailsPage> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends ConsumerState<SubjectDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to get updates (e.g. new grades)
    final subjects = ref.watch(educationProvider).asData?.value ?? [];
    // Find our subject in the list to be reactive
    final currentSubject = subjects.firstWhere(
      (s) => s.key == widget.subject.key,
      orElse: () => widget.subject,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSubject.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notas', icon: Icon(Icons.grade)),
            Tab(text: 'Calculadora', icon: Icon(Icons.calculate)),
            Tab(text: 'Notas', icon: Icon(Icons.note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GradesTab(subject: currentSubject),
          _CalculatorTab(subject: currentSubject),
          _NotesTab(subject: currentSubject),
        ],
      ),
    );
  }
}

class _GradesTab extends ConsumerWidget {
  final Subject subject;

  const _GradesTab({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grades = subject.grades;
    final average = _calculateAverage(grades, ref);
    final passing = subject.passingScore ?? 6.0;
    final isPassing = average >= passing;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Average Card
        Card(
          color: isPassing ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Média Atual',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  average.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: isPassing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPassing ? 'Aprovado' : 'Reprovado',
                  style: TextStyle(
                    color: isPassing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FilledButton.icon(
              onPressed: () => _showAddGradeDialog(context, ref, subject),
              icon: const Icon(Icons.add),
              label: const Text('Lançar Nota'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (grades.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Nenhuma nota lançada yet.'),
            ),
          )
        else
          ...grades.map(
            (grade) => Card(
              child: ListTile(
                title: Text(grade.name),
                subtitle: Text(
                  'Peso: ${grade.weight?.toStringAsFixed(1) ?? "1.0"} • ${DateFormat('dd/MM').format(grade.date)}',
                ),
                trailing: Text(
                  grade.score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLongPress: () => _confirmDelete(context, ref, subject, grade),
              ),
            ),
          ),
      ],
    );
  }

  double _calculateAverage(List<GradeEntry> grades, WidgetRef ref) {
    if (grades.isEmpty) return 0.0;

    String? formulaToCheck;

    // 1. Check for Linked Scheme
    if (subject.gradingSchemeId != null) {
      final schemes = ref.read(gradingSchemeProvider).asData?.value ?? [];
      // ignore: collection_methods_unrelated_type
      final scheme = schemes
          .where((s) => s.key == subject.gradingSchemeId)
          .firstOrNull;
      if (scheme != null) {
        formulaToCheck = scheme.formula;
      }
    }
    // 2. Check for legacy inline formula
    else if (subject.gradingFormula != null &&
        subject.gradingFormula!.trim().isNotEmpty) {
      formulaToCheck = subject.gradingFormula!;
    }

    if (formulaToCheck != null) {
      try {
        final parser = Parser();
        final expression = parser.parse(formulaToCheck);
        final context = ContextModel();

        // Aggregate scores by tag
        final tagSums = <String, double>{};
        for (var g in grades) {
          if (g.tag != null && g.tag!.isNotEmpty) {
            // User requested that acts with same tag be SUMMED (e.g. Activity 1 + Activity 2 = Final AP)
            tagSums[g.tag!] = (tagSums[g.tag!] ?? 0.0) + g.score;
          }
        }

        for (var entry in tagSums.entries) {
          context.bindVariable(Variable(entry.key), Number(entry.value));
        }
        return expression.evaluate(EvaluationType.REAL, context);
      } catch (e) {
        debugPrint('Formula Error: $e');
        return 0.0;
      }
    }

    // 3. Fallback to Weighted Average
    double weightedSum = 0;
    double totalWeight = 0;
    for (var g in grades) {
      final w = g.weight ?? 1.0;
      weightedSum += g.score * w;
      totalWeight += w;
    }
    if (totalWeight == 0) return 0.0;
    return weightedSum / totalWeight;
  }

  Future<void> _showAddGradeDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final nameController = TextEditingController();
    final scoreController = TextEditingController();
    final weightController = TextEditingController(text: '1.0');
    final tagController = TextEditingController();

    final result = await showDialog<GradeEntry>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome (ex: Prova)'),
            ),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Sigla/Tag (ex: N1)',
                helperText: 'Usado na fórmula personalizada',
              ),
            ),
            TextField(
              controller: scoreController,
              decoration: const InputDecoration(labelText: 'Nota'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Peso'),
              keyboardType: TextInputType.number,
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
              final weight = double.tryParse(weightController.text);
              if (score != null && weight != null) {
                Navigator.pop(
                  context,
                  GradeEntry()
                    ..name = nameController.text.isEmpty
                        ? 'Avaliação'
                        : nameController.text
                    ..tag = tagController.text.isEmpty
                        ? null
                        : tagController.text
                    ..score = score
                    ..weight = weight
                    ..date = DateTime.now(),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      ref.read(educationProvider.notifier).addGrade(subject.key, result);
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
    GradeEntry grade,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Nota'),
        content: Text('Deseja excluir ${grade.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(educationProvider.notifier).deleteGrade(grade);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _CalculatorTab extends StatelessWidget {
  final Subject subject;

  const _CalculatorTab({required this.subject});

  @override
  Widget build(BuildContext context) {
    // Simple logic: Assume user wants to know what they need on ONE final exam
    // Or users specifies remaining weight.
    // This is tricky without knowing total weights or "Game Rules".
    // Let's implement a simple "What do I need to pass?" based on current average?
    // No, that's not how it works.
    // Usually: (CurrentAvg * AccumWeight + Needed * RemainingWeight) / TotalWeight = Passing

    // Let's make a simplified UI where user inputs "Peso da próxima prova".

    return Center(child: Text("Calculadora de Notas (Em Breve)"));
  }
}

class _NotesTab extends ConsumerWidget {
  final Subject subject;

  const _NotesTab({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch subject updates
    final subjects = ref.watch(educationProvider).asData?.value ?? [];
    final currentSubject = subjects.firstWhere(
      (s) => s.key == subject.key,
      orElse: () => subject,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (currentSubject.notes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text("Nenhuma anotação.")),
          )
        else
          ...currentSubject.notes.map(
            (n) => Card(
              child: ListTile(
                title: Text(n),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref
                        .read(educationProvider.notifier)
                        .removeNote(currentSubject, n);
                  },
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _showAddNoteDialog(context, ref, currentSubject),
          icon: const Icon(Icons.add),
          label: const Text("Adicionar Anotação"),
        ),
      ],
    );
  }

  Future<void> _showAddNoteDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Anotação'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Digite sua anotação...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(educationProvider.notifier)
                    .addNote(subject, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
