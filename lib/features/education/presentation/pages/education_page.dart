import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';
import 'package:love_routine_app/features/education/presentation/providers/education_provider.dart';
import 'package:love_routine_app/features/education/presentation/widgets/subject_dialog.dart';
import 'package:love_routine_app/features/education/presentation/pages/subject_details_page.dart';
import 'package:love_routine_app/features/education/presentation/pages/grading_schemes_page.dart';
import 'package:love_routine_app/features/education/presentation/providers/grading_scheme_provider.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';

class EducationPage extends ConsumerWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(educationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Educação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.functions),
            tooltip: 'Gerenciar Fórmulas',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GradingSchemesPage(),
                ),
              );
            },
          ),
        ],
      ),
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
    // Use the same logic as details page? Ideally refactor to shared logic.
    // For now, simpler approximation or duplicate logic?
    // Let's rely on SubjectDetailsPage logic but simplified or copy logic.
    // Ideally put logic in Subject model or provider?
    // Let's assume standard weighted average for list view or implement formula calc here too.
    // To implement formula calc here we need gradingSchemeProvider.
    final average = _calculateAverage(grades, ref, subject);
    final passing = subject.passingScore ?? 6.0;
    final isPassing = average >= passing;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubjectDetailsPage(subject: subject),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12), // Match card shape
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.teacherName ?? 'Sem professor',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateAverage(
    List<GradeEntry> grades,
    WidgetRef ref,
    Subject subject,
  ) {
    if (grades.isEmpty) return 0.0;

    // Quick copy of logic from SubjectDetailsPage
    // TODO: Refactor into a shared utility or extension
    String? formulaToCheck;
    if (subject.gradingSchemeId != null) {
      final schemes = ref.read(gradingSchemeProvider).asData?.value ?? [];
      // ignore: collection_methods_unrelated_type
      final scheme = schemes
          .where((s) => s.key == subject.gradingSchemeId)
          .firstOrNull;
      if (scheme != null) formulaToCheck = scheme.formula;
    } else if (subject.gradingFormula != null &&
        subject.gradingFormula!.trim().isNotEmpty) {
      formulaToCheck = subject.gradingFormula!;
    }

    if (formulaToCheck != null) {
      try {
        final parser = Parser();
        final expression = parser.parse(formulaToCheck);
        final context = ContextModel();

        final tagSums = <String, double>{};
        for (var g in grades) {
          if (g.tag != null && g.tag!.isNotEmpty) {
            tagSums[g.tag!] = (tagSums[g.tag!] ?? 0.0) + g.score;
          }
        }
        for (var entry in tagSums.entries) {
          context.bindVariable(Variable(entry.key), Number(entry.value));
        }
        return expression.evaluate(EvaluationType.REAL, context);
      } catch (e) {
        return 0.0;
      }
    }

    // Default Weighted
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

  Future<void> _showSubjectDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Subject>(
      context: context,
      builder: (_) => const SubjectDialog(),
    );
    if (result != null) {
      ref.read(educationProvider.notifier).addSubject(result);
    }
  }
}
